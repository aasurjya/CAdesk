import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_message.dart';
import 'package:ca_app/core/ai/models/ai_model_config.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_tool_call.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Adapter for the Anthropic Claude Messages API.
class ClaudeAdapter implements AiGateway {
  ClaudeAdapter({
    required this.dio,
    required this.config,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Dio dio;
  final AiModelConfig config;
  final FlutterSecureStorage _secureStorage;

  static const _apiVersion = '2023-06-01';
  static const _apiKeyStorageKey = 'claude_api_key';

  Future<String> _getApiKey() async {
    final key = await _secureStorage.read(key: _apiKeyStorageKey);
    if (key == null || key.isEmpty) {
      throw const AuthError('Claude API key not configured');
    }
    return key;
  }

  @override
  Future<AiResponse> complete(AiRequest request) async {
    final apiKey = await _getApiKey();
    final body = _buildRequestBody(request);

    try {
      final response = await dio.post<Map<String, dynamic>>(
        config.endpoint,
        data: body,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': _apiVersion,
            'Content-Type': 'application/json',
          },
        ),
      );
      return _parseResponse(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    final apiKey = await _getApiKey();
    final body = _buildRequestBody(request, stream: true);

    try {
      final response = await dio.post<ResponseBody>(
        config.endpoint,
        data: body,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': _apiVersion,
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        buffer.write(text);

        // Parse SSE events from buffer
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;
            yield AiResponse(content: data);
          } else if (line.isNotEmpty) {
            buffer.write(line);
          }
        }
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<double>> embed(String text) async {
    // Claude does not natively support embeddings.
    // This adapter delegates to a separate embedding endpoint if configured.
    throw const ServiceUnavailableError(
      'Claude does not support embeddings natively',
    );
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await _getApiKey();
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _buildRequestBody(
    AiRequest request, {
    bool stream = false,
  }) {
    final messages = <Map<String, String>>[];
    for (final msg in request.messages) {
      if (msg.role == AiRole.system) continue; // system goes in top-level field
      messages.add({
        'role': msg.role == AiRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    final body = <String, dynamic>{
      'model': config.modelId,
      'messages': messages,
      'max_tokens': request.maxTokens,
      'temperature': request.temperature,
      if (stream) 'stream': true,
    };

    // Add system prompt
    final systemPrompt =
        request.systemPrompt ??
        request.messages
            .where((m) => m.role == AiRole.system)
            .map((m) => m.content)
            .join('\n');
    if (systemPrompt.isNotEmpty) {
      body['system'] = systemPrompt;
    }

    // Add tools
    if (request.tools.isNotEmpty) {
      body['tools'] = request.tools.map((t) => t.toJson()).toList();
    }

    return body;
  }

  AiResponse _parseResponse(Map<String, dynamic> data) {
    final content = _extractContent(data);
    final toolCalls = _extractToolCalls(data);
    final usage = _extractUsage(data);
    final stopReason = data['stop_reason'] as String?;

    return AiResponse(
      content: content,
      finishReason: _mapStopReason(stopReason),
      usage: usage,
      toolCalls: toolCalls,
    );
  }

  String _extractContent(Map<String, dynamic> data) {
    final contentBlocks = data['content'] as List<dynamic>?;
    if (contentBlocks == null || contentBlocks.isEmpty) return '';

    return contentBlocks
        .where((b) => (b as Map<String, dynamic>)['type'] == 'text')
        .map((b) => (b as Map<String, dynamic>)['text'] as String)
        .join();
  }

  List<AiToolCall> _extractToolCalls(Map<String, dynamic> data) {
    final contentBlocks = data['content'] as List<dynamic>?;
    if (contentBlocks == null) return const [];

    return contentBlocks
        .where((b) => (b as Map<String, dynamic>)['type'] == 'tool_use')
        .map((b) {
          final block = b as Map<String, dynamic>;
          return AiToolCall(
            id: block['id'] as String,
            toolName: block['name'] as String,
            arguments: Map<String, dynamic>.from(block['input'] as Map),
          );
        })
        .toList();
  }

  AiUsage _extractUsage(Map<String, dynamic> data) {
    final usage = data['usage'] as Map<String, dynamic>?;
    if (usage == null) return AiUsage.zero;

    return AiUsage(
      promptTokens: usage['input_tokens'] as int? ?? 0,
      completionTokens: usage['output_tokens'] as int? ?? 0,
    );
  }

  FinishReason _mapStopReason(String? reason) {
    return switch (reason) {
      'end_turn' || 'stop' => FinishReason.stop,
      'tool_use' => FinishReason.toolUse,
      'max_tokens' => FinishReason.maxTokens,
      _ => FinishReason.stop,
    };
  }

  AiError _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message ?? 'Unknown error';

    return switch (statusCode) {
      429 => RateLimitError(message),
      401 || 403 => AuthError(message),
      400 => ContentFilterError(message),
      500 ||
      502 ||
      503 => ServiceUnavailableError(message, statusCode: statusCode),
      _ => UnknownAiError(message, statusCode: statusCode),
    };
  }
}
