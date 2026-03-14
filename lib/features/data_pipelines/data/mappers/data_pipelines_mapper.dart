import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';

/// Converts between [DataPipeline] / [BrokerFeed] and JSON maps.
class DataPipelinesMapper {
  const DataPipelinesMapper._();

  static DataPipeline pipelineFromJson(Map<String, dynamic> json) {
    return DataPipeline(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceType: PipelineSourceType.values.firstWhere(
        (e) => e.name == (json['source_type'] as String? ?? 'tally'),
        orElse: () => PipelineSourceType.tally,
      ),
      status: PipelineStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => PipelineStatus.pending,
      ),
      lastSync: DateTime.parse(json['last_sync'] as String),
      recordsProcessed: (json['records_processed'] as num).toInt(),
      errorCount: (json['error_count'] as num).toInt(),
      nextSync: json['next_sync'] != null
          ? DateTime.parse(json['next_sync'] as String)
          : null,
      clientCount: json['client_count'] != null
          ? (json['client_count'] as num).toInt()
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  static Map<String, dynamic> pipelineToJson(DataPipeline pipeline) {
    return {
      'id': pipeline.id,
      'name': pipeline.name,
      'source_type': pipeline.sourceType.name,
      'status': pipeline.status.name,
      'last_sync': pipeline.lastSync.toIso8601String(),
      'records_processed': pipeline.recordsProcessed,
      'error_count': pipeline.errorCount,
      'next_sync': pipeline.nextSync?.toIso8601String(),
      'client_count': pipeline.clientCount,
      'error_message': pipeline.errorMessage,
    };
  }

  static BrokerFeed feedFromJson(Map<String, dynamic> json) {
    return BrokerFeed(
      id: json['id'] as String,
      broker: BrokerName.values.firstWhere(
        (e) => e.name == (json['broker'] as String? ?? 'zerodha'),
        orElse: () => BrokerName.zerodha,
      ),
      clientName: json['client_name'] as String,
      status: BrokerFeedStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'stale'),
        orElse: () => BrokerFeedStatus.stale,
      ),
      lastFetch: DateTime.parse(json['last_fetch'] as String),
      capitalGainsCount: (json['capital_gains_count'] as num).toInt(),
      totalTransactions: (json['total_transactions'] as num).toInt(),
      pan: json['pan'] as String?,
      accountId: json['account_id'] as String?,
    );
  }

  static Map<String, dynamic> feedToJson(BrokerFeed feed) {
    return {
      'id': feed.id,
      'broker': feed.broker.name,
      'client_name': feed.clientName,
      'status': feed.status.name,
      'last_fetch': feed.lastFetch.toIso8601String(),
      'capital_gains_count': feed.capitalGainsCount,
      'total_transactions': feed.totalTransactions,
      'pan': feed.pan,
      'account_id': feed.accountId,
    };
  }
}
