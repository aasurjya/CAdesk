// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portal_imports_dao.dart';

// ignore_for_file: type=lint
mixin _$PortalImportsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PortalImportsTableTable get portalImportsTable =>
      attachedDatabase.portalImportsTable;
  PortalImportsDaoManager get managers => PortalImportsDaoManager(this);
}

class PortalImportsDaoManager {
  final _$PortalImportsDaoMixin _db;
  PortalImportsDaoManager(this._db);
  $$PortalImportsTableTableTableManager get portalImportsTable =>
      $$PortalImportsTableTableTableManager(
        _db.attachedDatabase,
        _db.portalImportsTable,
      );
}
