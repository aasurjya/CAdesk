// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portal_connector_dao.dart';

// ignore_for_file: type=lint
mixin _$PortalConnectorDaoMixin on DatabaseAccessor<AppDatabase> {
  $PortalCredentialsTableTable get portalCredentialsTable =>
      attachedDatabase.portalCredentialsTable;
  PortalConnectorDaoManager get managers => PortalConnectorDaoManager(this);
}

class PortalConnectorDaoManager {
  final _$PortalConnectorDaoMixin _db;
  PortalConnectorDaoManager(this._db);
  $$PortalCredentialsTableTableTableManager get portalCredentialsTable =>
      $$PortalCredentialsTableTableTableManager(
        _db.attachedDatabase,
        _db.portalCredentialsTable,
      );
}
