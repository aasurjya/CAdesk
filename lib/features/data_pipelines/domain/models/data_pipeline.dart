import 'package:flutter/material.dart';

enum PipelineSourceType {
  form16('Form 16 / 16A'),
  form26as('Form 26AS / AIS / TIS'),
  zerodha('Zerodha'),
  cams('CAMS'),
  kfintech('KFintech'),
  karvy('Karvy'),
  groww('Groww'),
  angelOne('Angel One'),
  tally('Tally'),
  zohoBooks('Zoho Books'),
  quickbooks('QuickBooks'),
  sap('SAP');

  const PipelineSourceType(this.label);
  final String label;

  bool get isBroker =>
      [zerodha, cams, kfintech, karvy, groww, angelOne].contains(this);
}

enum PipelineStatus {
  active('Active', Color(0xFF1A7A3A)),
  paused('Paused', Color(0xFF718096)),
  error('Error', Color(0xFFC62828)),
  pending('Pending', Color(0xFFD4890E));

  const PipelineStatus(this.label, this.color);
  final String label;
  final Color color;
}

class DataPipeline {
  const DataPipeline({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.status,
    required this.lastSync,
    required this.recordsProcessed,
    required this.errorCount,
    this.nextSync,
    this.clientCount,
    this.errorMessage,
  });

  final String id;
  final String name;
  final PipelineSourceType sourceType;
  final PipelineStatus status;
  final DateTime lastSync;
  final int recordsProcessed;
  final int errorCount;
  final DateTime? nextSync;
  final int? clientCount;
  final String? errorMessage;
}
