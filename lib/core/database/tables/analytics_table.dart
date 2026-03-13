import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('AnalyticsSnapshotRow')
class AnalyticsSnapshotsTable extends Table {
  @override
  String get tableName => 'local_analytics_snapshots';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get period => text()(); // e.g. '2026-03'
  RealColumn get totalRevenue => real().withDefault(const Constant(0.0))();
  IntColumn get totalClients => integer().withDefault(const Constant(0))();
  IntColumn get filingCompleted => integer().withDefault(const Constant(0))();
  IntColumn get filingPending => integer().withDefault(const Constant(0))();
  RealColumn get avgResponseTime => real().withDefault(const Constant(0.0))();
  TextColumn get topModule => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ClientMetricRow')
class ClientMetricsTable extends Table {
  @override
  String get tableName => 'local_client_metrics';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get period => text()(); // e.g. '2026-03'
  RealColumn get revenue => real().withDefault(const Constant(0.0))();
  IntColumn get filingsCompleted => integer().withDefault(const Constant(0))();
  RealColumn get outstandingAmount => real().withDefault(const Constant(0.0))();
  RealColumn get satisfactionScore => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
