import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';

/// Local (SQLite via Drift) data source for data pipelines.
///
/// Note: full DAO wiring is deferred until the data_pipelines tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class DataPipelinesLocalSource {
  const DataPipelinesLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertPipeline(DataPipeline pipeline) async => pipeline.id;

  Future<List<DataPipeline>> getAllPipelines() async => const [];

  Future<bool> updatePipeline(DataPipeline pipeline) async => false;

  Future<bool> deletePipeline(String id) async => false;

  Future<String> insertBrokerFeed(BrokerFeed feed) async => feed.id;

  Future<List<BrokerFeed>> getAllBrokerFeeds() async => const [];

  Future<bool> updateBrokerFeed(BrokerFeed feed) async => false;

  Future<bool> deleteBrokerFeed(String id) async => false;
}
