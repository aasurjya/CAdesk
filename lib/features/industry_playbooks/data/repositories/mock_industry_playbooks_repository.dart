import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';
import 'package:ca_app/features/industry_playbooks/domain/repositories/industry_playbooks_repository.dart';

/// In-memory mock implementation of [IndustryPlaybooksRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockIndustryPlaybooksRepository implements IndustryPlaybooksRepository {
  static const List<VerticalPlaybook> _seedPlaybooks = [
    VerticalPlaybook(
      id: 'vp-ecommerce',
      vertical: 'e-Commerce',
      icon: '🛒',
      description:
          'High-turnover B2C businesses with complex GST compliance needs '
          'including TCS, marketplace reconciliation, and e-invoicing.',
      complianceChecklist: [
        'GSTR-1 / GSTR-3B monthly filing',
        'TCS collected by e-commerce operator (u/s 52)',
        'e-Invoicing for turnover > ₹5 Cr',
        'Annual GST reconciliation (GSTR-9/9C)',
      ],
      typicalRisks: [
        'ITC mismatch due to marketplace delays',
        'Wrong HSN classification for digital goods',
      ],
      activeClients: 14,
      avgRetainerValue: 6.5,
      winRate: 0.72,
      marginPercent: 0.41,
    ),
    VerticalPlaybook(
      id: 'vp-exporters',
      vertical: 'Exporters',
      icon: '🚢',
      description:
          'Manufacturers and service exporters claiming LUT/bond-based '
          'zero-rated GST benefits and handling FEMA compliance.',
      complianceChecklist: [
        'LUT (Letter of Undertaking) annual renewal',
        'GST refund on exports (IGST/ITC route)',
        'FEMA — Form 15CA/15CB for remittances',
        'DGFT compliance for advance authorisation',
      ],
      typicalRisks: [
        'GST refund delays and scrutiny',
        'FEMA penalty for delayed repatriation',
      ],
      activeClients: 9,
      avgRetainerValue: 8.0,
      winRate: 0.65,
      marginPercent: 0.38,
    ),
    VerticalPlaybook(
      id: 'vp-doctors',
      vertical: 'Doctors & Clinics',
      icon: '🏥',
      description:
          'Medical practitioners and small clinic operators with mixed '
          'taxable and exempt GST supplies and Section 44ADA presumptive income.',
      complianceChecklist: [
        'Section 44ADA presumptive tax (50% of gross receipts)',
        'Professional tax compliance (state-wise)',
        'GST on consultation fees vs exempt lab services',
        'TDS on equipment lease rentals',
      ],
      typicalRisks: [
        'Incorrect GST classification of medical services',
        'Undisclosed cash receipts from patients',
      ],
      activeClients: 22,
      avgRetainerValue: 3.2,
      winRate: 0.80,
      marginPercent: 0.45,
    ),
  ];

  static const List<ServiceBundle> _seedBundles = [
    ServiceBundle(
      id: 'sb-ecom-basic',
      verticalId: 'vp-ecommerce',
      name: 'e-Commerce Starter',
      description: 'Monthly GST compliance for small online sellers.',
      inclusions: [
        'GSTR-1 filing',
        'GSTR-3B filing',
        'TCS reconciliation',
        'Basic ITC matching',
      ],
      pricePerMonth: 4500,
      turnaroundDays: 3,
      slaLabel: 'T+3 days',
      isPopular: false,
    ),
    ServiceBundle(
      id: 'sb-ecom-pro',
      verticalId: 'vp-ecommerce',
      name: 'e-Commerce Pro',
      description:
          'Full GST compliance + e-invoicing + marketplace reconciliation.',
      inclusions: [
        'GSTR-1 / GSTR-3B',
        'e-Invoicing setup & support',
        'Marketplace reconciliation (Amazon/Flipkart)',
        'ITC mismatch resolution',
        'Quarterly GSTR-9C preparation',
      ],
      pricePerMonth: 9000,
      turnaroundDays: 2,
      slaLabel: 'T+2 days',
      isPopular: true,
    ),
    ServiceBundle(
      id: 'sb-export-full',
      verticalId: 'vp-exporters',
      name: 'Exporter Compliance Suite',
      description: 'End-to-end GST + FEMA compliance for exporters.',
      inclusions: [
        'LUT renewal',
        'GST refund filing (IGST / ITC route)',
        'Form 15CA / 15CB preparation',
        'Foreign exchange reconciliation',
        'DGFT filing support',
      ],
      pricePerMonth: 12000,
      turnaroundDays: 5,
      slaLabel: 'T+5 days',
      isPopular: true,
    ),
  ];

  final List<VerticalPlaybook> _playbooks = List.of(_seedPlaybooks);
  final List<ServiceBundle> _bundles = List.of(_seedBundles);

  // -------------------------------------------------------------------------
  // VerticalPlaybook
  // -------------------------------------------------------------------------

  @override
  Future<List<VerticalPlaybook>> getPlaybooks() async =>
      List.unmodifiable(_playbooks);

  @override
  Future<VerticalPlaybook?> getPlaybookById(String id) async {
    final matches = _playbooks.where((p) => p.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<VerticalPlaybook>> searchPlaybooks(String query) async {
    final q = query.toLowerCase();
    return List.unmodifiable(
      _playbooks
          .where(
            (p) =>
                p.vertical.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q),
          )
          .toList(),
    );
  }

  @override
  Future<String> insertPlaybook(VerticalPlaybook playbook) async {
    _playbooks.add(playbook);
    return playbook.id;
  }

  @override
  Future<bool> updatePlaybook(VerticalPlaybook playbook) async {
    final idx = _playbooks.indexWhere((p) => p.id == playbook.id);
    if (idx == -1) return false;
    final updated = List<VerticalPlaybook>.of(_playbooks)..[idx] = playbook;
    _playbooks
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deletePlaybook(String id) async {
    final before = _playbooks.length;
    _playbooks.removeWhere((p) => p.id == id);
    return _playbooks.length < before;
  }

  // -------------------------------------------------------------------------
  // ServiceBundle
  // -------------------------------------------------------------------------

  @override
  Future<List<ServiceBundle>> getBundlesByVertical(String verticalId) async =>
      List.unmodifiable(
        _bundles.where((b) => b.verticalId == verticalId).toList(),
      );

  @override
  Future<String> insertBundle(ServiceBundle bundle) async {
    _bundles.add(bundle);
    return bundle.id;
  }

  @override
  Future<bool> updateBundle(ServiceBundle bundle) async {
    final idx = _bundles.indexWhere((b) => b.id == bundle.id);
    if (idx == -1) return false;
    final updated = List<ServiceBundle>.of(_bundles)..[idx] = bundle;
    _bundles
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteBundle(String id) async {
    final before = _bundles.length;
    _bundles.removeWhere((b) => b.id == id);
    return _bundles.length < before;
  }
}
