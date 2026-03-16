import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_message.dart';
import 'package:ca_app/core/ai/models/ai_model_config.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Adapter for the Google Gemini API.
class GeminiAdapter implements AiGateway {
  GeminiAdapter({
    required this.dio,
    required this.config,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Dio dio;
  final AiModelConfig config;
  final FlutterSecureStorage _secureStorage;

  static const _apiKeyStorageKey = 'gemini_api_key';

  Future<String> _getApiKey() async {
    final key = await _secureStorage.read(key: _apiKeyStorageKey);
    if (key == null || key.isEmpty) {
      throw const AuthError('Gemini API key not configured');
    }
    return key;
  }

  @override
  Future<AiResponse> complete(AiRequest request) async {
    final apiKey = await _getApiKey();
    final body = _buildRequestBody(request);
    final url = '${config.endpoint}?key=$apiKey';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return _parseResponse(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    // Gemini uses streamGenerateContent endpoint
    final apiKey = await _getApiKey();
    final body = _buildRequestBody(request);
    final url =
        '${config.endpoint.replaceFirst(':generateContent', ':streamGenerateContent')}?key=$apiKey';

    try {
      final response = await dio.post<ResponseBody>(
        url,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.stream,
        ),
      );

      await for (final chunk in response.data!.stream) {
        final text = String.fromCharCodes(chunk);
        yield AiResponse(content: text);
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<double>> embed(String text) async {
    final apiKey = await _getApiKey();
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=$apiKey';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        data: {
          'model': 'models/text-embedding-004',
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        },
      );

      final embedding = response.data!['embedding']['values'] as List<dynamic>;
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

  Map<String, dynamic> _buildRequestBody(AiRequest request) {
    final contents = <Map<String, dynamic>>[];

    for (final msg in request.messages) {
      if (msg.role == AiRole.system) continue;
      contents.add({
        'role': msg.role == AiRole.user ? 'user' : 'model',
        'parts': [
          {'text': msg.content},
        ],
      });
    }

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'maxOutputTokens': request.maxTokens,
        'temperature': request.temperature,
      },
    };

    final systemPrompt = request.systemPrompt;
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemPrompt},
        ],
      };
    }

    return body;
  }

  AiResponse _parseResponse(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return AiResponse(content: '');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.map((p) => (p as Map)['text'] ?? '').join() ?? '';

    final usageMetadata = data['usageMetadata'] as Map<String, dynamic>?;

    return AiResponse(
      content: text,
      usage: usageMetadata != null
          ? AiUsage(
              promptTokens: usageMetadata['promptTokenCount'] as int? ?? 0,
              completionTokens:
                  usageMetadata['candidatesTokenCount'] as int? ?? 0,
            )
          : AiUsage.zero,
    );
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
