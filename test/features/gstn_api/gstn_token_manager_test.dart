import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';
import 'package:ca_app/features/gstn_api/domain/services/gstn_token_manager.dart';

void main() {
  late GstnTokenManager manager;
  late MockGstnRepository repo;

  setUp(() {
    manager = GstnTokenManager();
    repo = MockGstnRepository();
  });

  group('GstnTokenManager.getValidToken', () {
    test('returns a token for valid GSTIN', () async {
      final token = await manager.getValidToken('29AABCT1332L000', repo);
      expect(token.accessToken, isNotEmpty);
      expect(token.isExpired, isFalse);
    });

    test('caches token on second call for same GSTIN', () async {
      final token1 = await manager.getValidToken('29AABCT1332L000', repo);
      final token2 = await manager.getValidToken('29AABCT1332L000', repo);
      expect(token1.accessToken, token2.accessToken);
    });

    test('issues separate tokens for different GSTINs', () async {
      final token1 = await manager.getValidToken('29AABCT1332L000', repo);
      final token2 = await manager.getValidToken('27AABCT1332L001', repo);
      // Both should be valid; they may differ since mock generates fresh tokens
      expect(token1.isExpired, isFalse);
      expect(token2.isExpired, isFalse);
    });
  });

  group('GstnTokenManager.isTokenExpiringSoon', () {
    test('returns false for freshly issued token', () async {
      final token = await manager.getValidToken('29AABCT1332L000', repo);
      expect(manager.isTokenExpiringSoon(token), isFalse);
    });

    test('returns true for token expiring in 5 minutes', () {
      final token = GstnToken(
        accessToken: 'test-token',
        tokenType: 'Bearer',
        expiresIn: 300, // 5 minutes
        issuedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      // Remaining: 4 min < 10 min threshold → expiring soon
      expect(manager.isTokenExpiringSoon(token), isTrue);
    });

    test('returns false for token expiring in 30 minutes', () {
      final token = GstnToken(
        accessToken: 'test-token',
        tokenType: 'Bearer',
        expiresIn: 3600,
        issuedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      // Remaining: 30 min > 10 min threshold → not expiring soon
      expect(manager.isTokenExpiringSoon(token), isFalse);
    });

    test('returns true for already-expired token', () {
      final token = GstnToken(
        accessToken: 'test-token',
        tokenType: 'Bearer',
        expiresIn: 60,
        issuedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(manager.isTokenExpiringSoon(token), isTrue);
    });
  });

  group('GstnTokenManager.refreshToken', () {
    test('returns a new valid token', () async {
      final token = await manager.refreshToken('29AABCT1332L000', repo);
      expect(token.isExpired, isFalse);
    });

    test('updates cached token after refresh', () async {
      await manager.getValidToken('29AABCT1332L000', repo);
      final refreshed = await manager.refreshToken('29AABCT1332L000', repo);
      final retrieved = await manager.getValidToken('29AABCT1332L000', repo);
      expect(retrieved.accessToken, refreshed.accessToken);
    });
  });
}
