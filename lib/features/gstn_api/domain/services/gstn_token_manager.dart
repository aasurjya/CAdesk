import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

/// Manages GSTN access tokens with in-memory caching and expiry awareness.
///
/// Tokens are cached per GSTIN. A token is considered "expiring soon" when
/// its remaining lifetime falls below [_expiryBufferSeconds] (10 minutes).
/// The manager never mutates cached tokens — it always stores new instances.
class GstnTokenManager {
  static const int _expiryBufferSeconds = 10 * 60; // 10 minutes

  /// In-memory token cache keyed by GSTIN.
  final Map<String, GstnToken> _cache = {};

  /// Returns a valid (non-expired, non-expiring-soon) token for [gstin].
  ///
  /// If no cached token exists, or the cached token is expired / expiring
  /// soon, a new token is fetched via [repo] using empty credentials
  /// (appropriate for mock/dev environments).
  Future<GstnToken> getValidToken(String gstin, GstnRepository repo) async {
    final cached = _cache[gstin];
    if (cached != null && !cached.isExpired && !isTokenExpiringSoon(cached)) {
      return cached;
    }
    return refreshToken(gstin, repo);
  }

  /// Returns true when [token] will expire within [_expiryBufferSeconds].
  bool isTokenExpiringSoon(GstnToken token) {
    if (token.isExpired) return true;
    final remaining = token.expiresAt.difference(DateTime.now()).inSeconds;
    return remaining < _expiryBufferSeconds;
  }

  /// Fetches a fresh token from [repo] for [gstin] and caches it.
  ///
  /// Using empty username/otp is intentional here — the mock repository
  /// ignores these values. Live implementations should supply real credentials
  /// via a separate credential store passed into this method.
  Future<GstnToken> refreshToken(String gstin, GstnRepository repo) async {
    final token = await repo.getToken(gstin, '', '');
    _cache[gstin] = token;
    return token;
  }
}
