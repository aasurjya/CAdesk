import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';

/// Abstract interface for all AI model adapters.
///
/// Implementations must handle authentication, request formatting, and error
/// mapping for their specific provider (Claude, OpenAI, Gemini, mock, etc.).
abstract class AiGateway {
  /// Sends a request and returns a single complete response.
  Future<AiResponse> complete(AiRequest request);

  /// Sends a request and returns a stream of partial responses.
  Stream<AiResponse> streamComplete(AiRequest request);

  /// Generates an embedding vector for the given [text].
  Future<List<double>> embed(String text);

  /// Returns `true` if the adapter's backend is currently reachable.
  Future<bool> isAvailable();
}
