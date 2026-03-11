import 'package:flutter/material.dart';

enum BrokerName {
  zerodha('Zerodha'),
  cams('CAMS'),
  kfintech('KFintech'),
  karvy('Karvy'),
  groww('Groww'),
  angelOne('Angel One');

  const BrokerName(this.label);
  final String label;
}

enum BrokerFeedStatus {
  synced('Synced', Color(0xFF1A7A3A)),
  syncing('Syncing', Color(0xFFD4890E)),
  stale('Stale', Color(0xFF718096)),
  failed('Failed', Color(0xFFC62828));

  const BrokerFeedStatus(this.label, this.color);
  final String label;
  final Color color;
}

class BrokerFeed {
  const BrokerFeed({
    required this.id,
    required this.broker,
    required this.clientName,
    required this.status,
    required this.lastFetch,
    required this.capitalGainsCount,
    required this.totalTransactions,
    this.pan,
    this.accountId,
  });

  final String id;
  final BrokerName broker;
  final String clientName;
  final BrokerFeedStatus status;
  final DateTime lastFetch;
  final int capitalGainsCount;
  final int totalTransactions;
  final String? pan;
  final String? accountId;
}
