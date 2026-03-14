import 'package:flutter/material.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

/// Converts between [IntegrationConnector] / [MarketplaceApp] and JSON maps.
class EcosystemMapper {
  const EcosystemMapper._();

  static IntegrationConnector connectorFromJson(Map<String, dynamic> json) {
    return IntegrationConnector(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ConnectorCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'accounting'),
        orElse: () => ConnectorCategory.accounting,
      ),
      status: ConnectorStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'disconnected'),
        orElse: () => ConnectorStatus.disconnected,
      ),
      description: json['description'] as String,
      lastHeartbeat: json['last_heartbeat'] != null
          ? DateTime.parse(json['last_heartbeat'] as String)
          : null,
      latencyMs: json['latency_ms'] != null
          ? (json['latency_ms'] as num).toInt()
          : null,
      webhookUrl: json['webhook_url'] as String?,
      provider: json['provider'] as String?,
    );
  }

  static Map<String, dynamic> connectorToJson(IntegrationConnector c) {
    return {
      'id': c.id,
      'name': c.name,
      'category': c.category.name,
      'status': c.status.name,
      'description': c.description,
      'last_heartbeat': c.lastHeartbeat?.toIso8601String(),
      'latency_ms': c.latencyMs,
      'webhook_url': c.webhookUrl,
      'provider': c.provider,
    };
  }

  static MarketplaceApp appFromJson(Map<String, dynamic> json) {
    return MarketplaceApp(
      id: json['id'] as String,
      name: json['name'] as String,
      vendor: json['vendor'] as String,
      category: AppCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'banking'),
        orElse: () => AppCategory.banking,
      ),
      installStatus: AppInstallStatus.values.firstWhere(
        (e) => e.name == (json['install_status'] as String? ?? 'available'),
        orElse: () => AppInstallStatus.available,
      ),
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['review_count'] as num).toInt(),
      isFree: json['is_free'] as bool? ?? true,
      pricePerMonth: json['price_per_month'] != null
          ? (json['price_per_month'] as num).toDouble()
          : null,
      installedAt: json['installed_at'] != null
          ? DateTime.parse(json['installed_at'] as String)
          : null,
      iconColor: json['icon_color'] != null
          ? Color((json['icon_color'] as num).toInt())
          : null,
    );
  }

  static Map<String, dynamic> appToJson(MarketplaceApp app) {
    return {
      'id': app.id,
      'name': app.name,
      'vendor': app.vendor,
      'category': app.category.name,
      'install_status': app.installStatus.name,
      'description': app.description,
      'rating': app.rating,
      'review_count': app.reviewCount,
      'is_free': app.isFree,
      'price_per_month': app.pricePerMonth,
      'installed_at': app.installedAt?.toIso8601String(),
      'icon_color': app.iconColor?.toARGB32(),
    };
  }
}
