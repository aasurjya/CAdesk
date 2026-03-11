import 'package:flutter/material.dart';

enum ConnectorCategory {
  government('Government APIs'),
  payment('Payment Gateways'),
  esign('E-Sign'),
  kyc('Video KYC'),
  messaging('Messaging'),
  accounting('Accounting');

  const ConnectorCategory(this.label);
  final String label;
}

enum ConnectorStatus {
  connected('Connected', Color(0xFF1A7A3A)),
  disconnected('Disconnected', Color(0xFF718096)),
  error('Error', Color(0xFFC62828)),
  beta('Beta', Color(0xFF0D7C7C));

  const ConnectorStatus(this.label, this.color);
  final String label;
  final Color color;
}

class IntegrationConnector {
  const IntegrationConnector({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    this.lastHeartbeat,
    this.latencyMs,
    this.webhookUrl,
    this.provider,
  });

  final String id;
  final String name;
  final ConnectorCategory category;
  final ConnectorStatus status;
  final String description;
  final DateTime? lastHeartbeat;
  final int? latencyMs;
  final String? webhookUrl;
  final String? provider;
}
