/// Conflict resolution strategy: server-wins by default.
class ConflictResolver {
  const ConflictResolver();

  /// Resolves conflict between local and server payloads.
  /// Returns the resolved payload (server wins) and the resolution type.
  ConflictResolution resolve({
    required Map<String, dynamic> localPayload,
    required Map<String, dynamic> serverPayload,
  }) {
    // Server-wins strategy: server payload always takes precedence
    return ConflictResolution(
      resolvedPayload: serverPayload,
      strategy: ResolutionStrategy.serverWins,
    );
  }
}

enum ResolutionStrategy { serverWins, localWins, manual }

class ConflictResolution {
  const ConflictResolution({
    required this.resolvedPayload,
    required this.strategy,
  });

  final Map<String, dynamic> resolvedPayload;
  final ResolutionStrategy strategy;
}
