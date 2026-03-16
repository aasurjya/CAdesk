import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';

/// Routes requests to the best available [AiGateway] adapter.
///
/// Tries adapters in priority order, falling back to the next if unavailable.
class RoutingAiGateway implements AiGateway {
  RoutingAiGateway(List<AiGateway> adapters)
      : _adapters = List.unmodifiable(adapters);

  final List<AiGateway> _adapters;

  Future<AiGateway> _resolveAdapter() async {
    for (final adapter in _adapters) {
      if (await adapter.isAvailable()) {
        return adapter;
      }
    }
    // Fallback to first adapter — it will throw a meaningful error.
    return _adapters.first;
  }

  @override
  Future<AiResponse> complete(AiRequest request) async {
    final adapter = await _resolveAdapter();
    return adapter.complete(request);
  }

  @override
  Stream<AiResponse> streamComplete(AiRequest request) async* {
    final adapter = await _resolveAdapter();
    yield* adapter.streamComplete(request);
  }

  @override
  Future<List<double>> embed(String text) async {
    final adapter = await _resolveAdapter();
    return adapter.embed(text);
  }

  @override
  Future<bool> isAvailable() async {
    for (final adapter in _adapters) {
      if (await adapter.isAvailable()) return true;
    }
    return false;
  }
}
