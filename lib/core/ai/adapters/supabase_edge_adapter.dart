import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Proxies AI calls through Supabase Edge Functions.
///
/// Keeps API keys server-side. The Edge Function handles model selection
/// and rate limiting centrally.
class SupabaseEdgeAdapter implements AiGateway {
  const SupabaseEdgeAdapter({this.functionName = 'ai-gateway'});

  final String functionName;

  @override
  Future<AiResponse> complete(AiRequest request) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.functions.invoke(
        functionName,
        body: _buildRequestBody(request),
      );

      final data = response.data as Map<String, dynamic>;
      return _parseResponse(data);
    } catch (e) {
      throw ServiceUnavailableError('Edge Function error: $e');
    }
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    // Edge Functions don't easily support SSE; fall back to complete.
    yield await complete(request);
  }

  @override
  Future<List<double>> embed(String text) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.functions.invoke(
        '$functionName-embed',
        body: {'text': text},
      );

      final data = response.data as Map<String, dynamic>;
      final embedding = data['embedding'] as List<dynamic>;
      return embedding.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      throw ServiceUnavailableError('Edge Function embed error: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _buildRequestBody(AiRequest request) {
    return {
      'messages': request.messages
          .map((m) => {'role': m.role.name, 'content': m.content})
          .toList(),
      'system_prompt': request.systemPrompt,
      'max_tokens': request.maxTokens,
      'temperature': request.temperature,
    };
  }

  AiResponse _parseResponse(Map<String, dynamic> data) {
    return AiResponse(
      content: data['content'] as String? ?? '',
      usage: AiUsage(
        promptTokens: data['prompt_tokens'] as int? ?? 0,
        completionTokens: data['completion_tokens'] as int? ?? 0,
      ),
    );
  }
}
