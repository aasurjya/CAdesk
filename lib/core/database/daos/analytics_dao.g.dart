// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_dao.dart';

// ignore_for_file: type=lint
mixin _$AnalyticsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnalyticsSnapshotsTableTable get analyticsSnapshotsTable =>
      attachedDatabase.analyticsSnapshotsTable;
  $ClientMetricsTableTable get clientMetricsTable =>
      attachedDatabase.clientMetricsTable;
  AnalyticsDaoManager get managers => AnalyticsDaoManager(this);
}

class AnalyticsDaoManager {
  final _$AnalyticsDaoMixin _db;
  AnalyticsDaoManager(this._db);
  $$AnalyticsSnapshotsTableTableTableManager get analyticsSnapshotsTable =>
      $$AnalyticsSnapshotsTableTableTableManager(
        _db.attachedDatabase,
        _db.analyticsSnapshotsTable,
      );
  $$ClientMetricsTableTableTableManager get clientMetricsTable =>
      $$ClientMetricsTableTableTableManager(
        _db.attachedDatabase,
        _db.clientMetricsTable,
      );
}
