import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/integration_connector.dart';
import '../../domain/models/marketplace_app.dart';

// ---------------------------------------------------------------------------
// Mock data - Integration Connectors
// ---------------------------------------------------------------------------

final List<IntegrationConnector> _mockConnectors = [
  IntegrationConnector(
    id: 'conn-001',
    name: 'GSTN API',
    category: ConnectorCategory.government,
    status: ConnectorStatus.connected,
    description: 'GST Network API for filing returns and fetching GSTIN data',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 45),
    latencyMs: 142,
    webhookUrl: 'https://api.gst.gov.in/v1.0/returns',
    provider: 'GSTN',
  ),
  IntegrationConnector(
    id: 'conn-002',
    name: 'MCA Portal',
    category: ConnectorCategory.government,
    status: ConnectorStatus.connected,
    description: 'Ministry of Corporate Affairs API for company filings',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 30),
    latencyMs: 210,
    webhookUrl: 'https://www.mca.gov.in/mcafoportal/rest/v1',
    provider: 'MCA',
  ),
  IntegrationConnector(
    id: 'conn-003',
    name: 'TRACES',
    category: ConnectorCategory.government,
    status: ConnectorStatus.error,
    description: 'TDS Reconciliation Analysis and Correction Enabling System',
    lastHeartbeat: DateTime(2026, 3, 10, 7, 15),
    latencyMs: null,
    webhookUrl: 'https://www.tdscpc.gov.in/app/api',
    provider: 'CBDT',
  ),
  IntegrationConnector(
    id: 'conn-004',
    name: 'RBI APIs',
    category: ConnectorCategory.government,
    status: ConnectorStatus.connected,
    description: 'Reserve Bank of India APIs for FEMA reporting and forex data',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 50),
    latencyMs: 98,
    webhookUrl: 'https://rbidocs.rbi.org.in/api/v2',
    provider: 'RBI',
  ),
  IntegrationConnector(
    id: 'conn-005',
    name: 'Razorpay',
    category: ConnectorCategory.payment,
    status: ConnectorStatus.connected,
    description: 'Razorpay payment gateway for client fee collection',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 55),
    latencyMs: 67,
    webhookUrl: 'https://api.razorpay.com/v1/payments',
    provider: 'Razorpay',
  ),
  IntegrationConnector(
    id: 'conn-006',
    name: 'PayU',
    category: ConnectorCategory.payment,
    status: ConnectorStatus.disconnected,
    description: 'PayU payment gateway — secondary payment processor',
    lastHeartbeat: DateTime(2026, 3, 8, 14, 20),
    latencyMs: null,
    webhookUrl: 'https://info.payu.in/merchant/v1',
    provider: 'PayU',
  ),
  IntegrationConnector(
    id: 'conn-007',
    name: 'Aadhaar e-Sign',
    category: ConnectorCategory.esign,
    status: ConnectorStatus.connected,
    description: 'UIDAI Aadhaar-based e-signature for client documents',
    lastHeartbeat: DateTime(2026, 3, 10, 8, 30),
    latencyMs: 185,
    webhookUrl: 'https://esignservice.cdac.in/esign2.1',
    provider: 'C-DAC',
  ),
  IntegrationConnector(
    id: 'conn-008',
    name: 'Digio',
    category: ConnectorCategory.esign,
    status: ConnectorStatus.beta,
    description: 'Digio e-sign and document workflow automation platform',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 10),
    latencyMs: 155,
    webhookUrl: 'https://ext.digio.in/v2/client',
    provider: 'Digio',
  ),
  IntegrationConnector(
    id: 'conn-009',
    name: 'VideoKYC.in',
    category: ConnectorCategory.kyc,
    status: ConnectorStatus.connected,
    description: 'Video KYC solution for remote client onboarding',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 40),
    latencyMs: 220,
    webhookUrl: 'https://api.videokyc.in/v1/sessions',
    provider: 'VideoKYC.in',
  ),
  IntegrationConnector(
    id: 'conn-010',
    name: 'WhatsApp Business API',
    category: ConnectorCategory.messaging,
    status: ConnectorStatus.connected,
    description: 'WhatsApp Business Cloud API for client notifications',
    lastHeartbeat: DateTime(2026, 3, 10, 9, 58),
    latencyMs: 55,
    webhookUrl: 'https://graph.facebook.com/v18.0/messages',
    provider: 'Meta',
  ),
  IntegrationConnector(
    id: 'conn-011',
    name: 'Tally API',
    category: ConnectorCategory.accounting,
    status: ConnectorStatus.beta,
    description: 'Tally ERP integration for accounting data sync',
    lastHeartbeat: DateTime(2026, 3, 10, 6, 0),
    latencyMs: 310,
    webhookUrl: 'http://localhost:9000/tally',
    provider: 'Tally Solutions',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Marketplace Apps
// ---------------------------------------------------------------------------

final List<MarketplaceApp> _mockApps = [
  MarketplaceApp(
    id: 'app-001',
    name: 'ValuPro',
    vendor: 'ValuPro Technologies',
    category: AppCategory.valuation,
    installStatus: AppInstallStatus.installed,
    description: 'Business valuation tool with DCF and comparable analysis',
    rating: 4.6,
    reviewCount: 128,
    isFree: false,
    pricePerMonth: 1499,
    installedAt: DateTime(2026, 1, 15),
    iconColor: const Color(0xFF1B3A5C),
  ),
  MarketplaceApp(
    id: 'app-002',
    name: 'LexDraft',
    vendor: 'LexCraft Solutions',
    category: AppCategory.legal,
    installStatus: AppInstallStatus.installed,
    description: 'AI-powered legal document drafting for CA firm agreements',
    rating: 4.3,
    reviewCount: 87,
    isFree: false,
    pricePerMonth: 999,
    installedAt: DateTime(2026, 2, 1),
    iconColor: const Color(0xFF0D7C7C),
  ),
  const MarketplaceApp(
    id: 'app-003',
    name: 'PayRoll360',
    vendor: 'HRNext Pvt Ltd',
    category: AppCategory.payroll,
    installStatus: AppInstallStatus.available,
    description: 'Full-service payroll processing with PF, ESI and TDS',
    rating: 4.1,
    reviewCount: 213,
    isFree: false,
    pricePerMonth: 799,
    iconColor: Color(0xFFE8890C),
  ),
  const MarketplaceApp(
    id: 'app-004',
    name: 'BankConnect',
    vendor: 'Finvu Technologies',
    category: AppCategory.banking,
    installStatus: AppInstallStatus.pending,
    description: 'Bank statement analyzer and reconciliation automation',
    rating: 4.5,
    reviewCount: 56,
    isFree: true,
    iconColor: Color(0xFF1A7A3A),
  ),
  const MarketplaceApp(
    id: 'app-005',
    name: 'InsureCalc',
    vendor: 'RiskSmart India',
    category: AppCategory.insurance,
    installStatus: AppInstallStatus.available,
    description: 'Insurance premium calculation and portfolio management',
    rating: 3.8,
    reviewCount: 34,
    isFree: true,
    iconColor: Color(0xFFC62828),
  ),
  const MarketplaceApp(
    id: 'app-006',
    name: 'HireRight',
    vendor: 'PeopleFirst HR',
    category: AppCategory.hr,
    installStatus: AppInstallStatus.deprecated,
    description: 'Background verification and onboarding — legacy version',
    rating: 3.2,
    reviewCount: 19,
    isFree: false,
    pricePerMonth: 499,
    iconColor: Color(0xFF718096),
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All integration connectors.
final integrationConnectorsProvider = Provider<List<IntegrationConnector>>(
  (_) => List.unmodifiable(_mockConnectors),
);

/// All marketplace apps.
final marketplaceAppsProvider = Provider<List<MarketplaceApp>>(
  (_) => List.unmodifiable(_mockApps),
);

/// Selected connector status filter.
final connectorStatusFilterProvider =
    NotifierProvider<ConnectorStatusFilterNotifier, ConnectorStatus?>(
      ConnectorStatusFilterNotifier.new,
    );

class ConnectorStatusFilterNotifier extends Notifier<ConnectorStatus?> {
  @override
  ConnectorStatus? build() => null;

  void update(ConnectorStatus? value) => state = value;
}

/// Integration connectors filtered by selected status.
final filteredConnectorsProvider = Provider<List<IntegrationConnector>>((ref) {
  final status = ref.watch(connectorStatusFilterProvider);
  final all = ref.watch(integrationConnectorsProvider);
  if (status == null) return all;
  return all.where((c) => c.status == status).toList();
});

/// Ecosystem summary statistics.
final ecosystemSummaryProvider = Provider<EcosystemSummary>((ref) {
  final connectors = ref.watch(integrationConnectorsProvider);
  final apps = ref.watch(marketplaceAppsProvider);

  final totalConnectors = connectors.length;
  final connectedConnectors = connectors
      .where((c) => c.status == ConnectorStatus.connected)
      .length;
  final errorConnectors = connectors
      .where((c) => c.status == ConnectorStatus.error)
      .length;
  final installedApps = apps
      .where((a) => a.installStatus == AppInstallStatus.installed)
      .length;

  return EcosystemSummary(
    totalConnectors: totalConnectors,
    connectedConnectors: connectedConnectors,
    errorConnectors: errorConnectors,
    installedApps: installedApps,
  );
});

// ---------------------------------------------------------------------------
// Immutable summary data class
// ---------------------------------------------------------------------------

class EcosystemSummary {
  const EcosystemSummary({
    required this.totalConnectors,
    required this.connectedConnectors,
    required this.errorConnectors,
    required this.installedApps,
  });

  final int totalConnectors;
  final int connectedConnectors;
  final int errorConnectors;
  final int installedApps;
}
