import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/portal_connector_table.dart';

part 'portal_connector_dao.g.dart';

@DriftAccessor(tables: [PortalCredentialsTable])
class PortalConnectorDao extends DatabaseAccessor<AppDatabase>
    with _$PortalConnectorDaoMixin {
  PortalConnectorDao(super.db);

  /// Insert (or replace) a credential row and return its ID.
  ///
  /// Each portal type is unique — any existing row for the same portalType
  /// is deleted before inserting the new one.
  Future<String> storeCredential(
    PortalCredentialsTableCompanion companion,
  ) async {
    await transaction(() async {
      // Remove any pre-existing row for this portalType to maintain uniqueness.
      await (delete(portalCredentialsTable)
            ..where((t) => t.portalType.equals(companion.portalType.value)))
          .go();
      await into(portalCredentialsTable).insert(companion);
    });
    return companion.id.value;
  }

  /// Retrieve the credential row for a given [portalType] string, or `null`.
  Future<PortalCredentialsTableData?> getCredential(String portalType) =>
      (select(portalCredentialsTable)
            ..where((t) => t.portalType.equals(portalType))
            ..limit(1))
          .getSingleOrNull();

  /// Replace an existing credential row.
  /// Returns `true` if a row was actually updated.
  Future<bool> updateCredential(
    PortalCredentialsTableCompanion companion,
  ) async {
    final existing = await (select(portalCredentialsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .getSingleOrNull();
    if (existing == null) return false;
    await (update(portalCredentialsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
    return true;
  }

  /// Delete the credential row for [portalType].
  /// Returns `true` if a row was deleted.
  Future<bool> deleteCredential(String portalType) async {
    final count = await (delete(portalCredentialsTable)
          ..where((t) => t.portalType.equals(portalType)))
        .go();
    return count > 0;
  }

  /// Return the current status string for [portalType], or `null`.
  Future<String?> getSyncStatus(String portalType) async {
    final row = await (select(portalCredentialsTable)
          ..where((t) => t.portalType.equals(portalType)))
        .getSingleOrNull();
    return row?.status;
  }

  /// Update only the status field for the credential matching [portalType].
  /// Returns `true` if a row was updated.
  Future<bool> updateSyncStatus(String portalType, String status) async {
    final count = await (update(portalCredentialsTable)
          ..where((t) => t.portalType.equals(portalType)))
        .write(
          PortalCredentialsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }
}
