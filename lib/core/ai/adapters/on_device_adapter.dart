import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';

/// Adapter for on-device local models (offline + privacy).
///
/// This is a placeholder that delegates to a local inference engine
/// when one is available. Falls back to the mock adapter pattern for now.
class OnDeviceAdapter implements AiGateway {
  const OnDeviceAdapter();

  @override
  Future<AiResponse> complete(AiRequest request) async {
    // TODO: Integrate with local model runtime (e.g., llama.cpp via FFI)
    throw const ServiceUnavailableError(
      'On-device model not available. Install a local model to enable offline mode.',
    );
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    throw const ServiceUnavailableError(
      'On-device model not available.',
    );
  }

  @override
  Future<List<double>> embed(String text) async {
    throw const ServiceUnavailableError(
      'On-device embedding not available.',
    );
  }

  @override
  Future<bool> isAvailable() async => false;
}
