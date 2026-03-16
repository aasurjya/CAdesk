import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_message.dart';
import 'package:ca_app/core/ai/models/ai_model_config.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Adapter for the OpenAI Chat Completions API.
class OpenAiAdapter implements AiGateway {
  OpenAiAdapter({
    required this.dio,
    required this.config,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Dio dio;
  final AiModelConfig config;
  final FlutterSecureStorage _secureStorage;

  static const _apiKeyStorageKey = 'openai_api_key';

  Future<String> _getApiKey() async {
    final key = await _secureStorage.read(key: _apiKeyStorageKey);
    if (key == null || key.isEmpty) {
      throw const AuthError('OpenAI API key not configured');
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
            'Authorization': 'Bearer $apiKey',
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
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        if (text.contains('[DONE]')) return;
        yield AiResponse(content: text);
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<double>> embed(String text) async {
    final apiKey = await _getApiKey();

    try {
      final response = await dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/embeddings',
        data: {'model': 'text-embedding-3-small', 'input': text},
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data!['data'] as List<dynamic>;
      final embedding = data.first['embedding'] as List<dynamic>;
      return embedding.map((e) => (e as num).toDouble()).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
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

    final systemPrompt = request.systemPrompt ?? '';
    if (systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    for (final msg in request.messages) {
      final role = switch (msg.role) {
        AiRole.system => 'system',
        AiRole.user => 'user',
        AiRole.assistant => 'assistant',
        AiRole.tool => 'tool',
      };
      messages.add({'role': role, 'content': msg.content});
    }

    return {
      'model': config.modelId,
      'messages': messages,
      'max_tokens': request.maxTokens,
      'temperature': request.temperature,
      if (stream) 'stream': true,
    };
  }

  AiResponse _parseResponse(Map<String, dynamic> data) {
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return AiResponse(content: '');
    }

    final choice = choices.first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;
    final content = message['content'] as String? ?? '';
    final finishReason = choice['finish_reason'] as String?;

    final usage = data['usage'] as Map<String, dynamic>?;

    return AiResponse(
      content: content,
      finishReason: _mapFinishReason(finishReason),
      usage: usage != null
          ? AiUsage(
              promptTokens: usage['prompt_tokens'] as int? ?? 0,
              completionTokens: usage['completion_tokens'] as int? ?? 0,
            )
          : AiUsage.zero,
    );
  }

  FinishReason _mapFinishReason(String? reason) {
    return switch (reason) {
      'stop' => FinishReason.stop,
      'tool_calls' => FinishReason.toolUse,
      'length' => FinishReason.maxTokens,
      'content_filter' => FinishReason.contentFilter,
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
