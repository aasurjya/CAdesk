import 'package:ca_app/features/gst/domain/models/reverse_charge.dart';

/// A notified service under Section 9(3) CGST Act.
class _NotifiedService {
  const _NotifiedService({
    required this.sacPrefix,
    required this.category,
    required this.description,
  });

  /// SAC code prefix that triggers this notification.
  final String sacPrefix;

  /// Category name for the notified service.
  final String category;

  /// Human-readable description.
  final String description;
}

/// Static service for detecting Reverse Charge Mechanism (RCM) applicability
/// under Sections 9(3), 9(4), and 9(5) of the CGST Act, 2017.
class RcmDetectionEngine {
  RcmDetectionEngine._();

  /// Section 9(3) notified services — services where the recipient is
  /// liable to pay GST under reverse charge.
  static const List<_NotifiedService> _notifiedServices = [
    _NotifiedService(
      sacPrefix: '9982',
      category: 'Legal services by advocate',
      description:
          'Services supplied by an individual advocate or firm of advocates',
    ),
    _NotifiedService(
      sacPrefix: '9965',
      category: 'GTA services',
      description: 'Services by a goods transport agency (GTA)',
    ),
    _NotifiedService(
      sacPrefix: '9967',
      category: 'GTA supporting services',
      description: 'Supporting services in transport by GTA',
    ),
    _NotifiedService(
      sacPrefix: '9985',
      category: 'Security and manpower services',
      description:
          'Security services and supply of manpower for security purposes',
    ),
    _NotifiedService(
      sacPrefix: '9966',
      category: 'Renting of motor vehicle',
      description:
          'Services of renting of a motor vehicle provided to a body corporate',
    ),
    _NotifiedService(
      sacPrefix: '997311',
      category: 'Director services',
      description: 'Services supplied by a director of a company',
    ),
    _NotifiedService(
      sacPrefix: '997112',
      category: 'Insurance agent services',
      description: 'Services by an insurance agent to an insurance company',
    ),
    _NotifiedService(
      sacPrefix: '997119',
      category: 'Recovery agent services',
      description:
          'Services by a recovery agent to a banking or financial institution',
    ),
    _NotifiedService(
      sacPrefix: '998397',
      category: 'Sponsorship services',
      description:
          'Services by way of sponsorship to any body corporate or firm',
    ),
    _NotifiedService(
      sacPrefix: '9991',
      category: 'Government services',
      description:
          'Services supplied by Central/State Government (excluding specific exemptions)',
    ),
    _NotifiedService(
      sacPrefix: '9986',
      category: 'Raw cotton supply',
      description: 'Supply of raw cotton by an agriculturist',
    ),
    _NotifiedService(
      sacPrefix: '2401',
      category: 'Tobacco leaves',
      description: 'Supply of tobacco leaves',
    ),
    _NotifiedService(
      sacPrefix: '5004',
      category: 'Silk yarn',
      description: 'Supply of silk yarn by a manufacturer',
    ),
    _NotifiedService(
      sacPrefix: '999692',
      category: 'Lottery distributor',
      description: 'Services by lottery distributor or selling agent',
    ),
    _NotifiedService(
      sacPrefix: '999611',
      category: 'Copyright (author to publisher)',
      description:
          'Transfer or permitting the use of copyright by author to publisher',
    ),
  ];

  /// Detects whether Reverse Charge Mechanism applies to a supply.
  ///
  /// Checks in order:
  /// 1. Section 9(5): E-commerce operator scenarios
  /// 2. Section 9(3): Notified services (SAC code match)
  /// 3. Section 9(4): Unregistered supplier
  static RcmResult detect({
    required String sacCode,
    required bool isSupplierRegistered,
    String? supplierType,
    bool isEcommerce = false,
  }) {
    // Section 9(5): E-commerce operator is liable for specified services.
    if (isEcommerce) {
      return const RcmResult(
        isRcmApplicable: true,
        rcmSection: RcmSection.section9_5,
        serviceCategory: 'E-commerce operator',
        reason: 'E-commerce operator liable under Section 9(5) CGST Act',
        selfInvoiceRequired: false,
      );
    }

    // Section 9(3): Check if the SAC code matches a notified service.
    for (final service in _notifiedServices) {
      if (sacCode.startsWith(service.sacPrefix) ||
          sacCode == service.sacPrefix) {
        return RcmResult(
          isRcmApplicable: true,
          rcmSection: RcmSection.section9_3,
          serviceCategory: service.category,
          reason: '${service.category} — notified under Section 9(3) CGST Act',
          selfInvoiceRequired: true,
        );
      }
    }

    // Section 9(4): Supply from unregistered person to registered person.
    if (!isSupplierRegistered) {
      return const RcmResult(
        isRcmApplicable: true,
        rcmSection: RcmSection.section9_4,
        serviceCategory: null,
        reason:
            'Supply from unregistered person — RCM under Section 9(4) CGST Act',
        selfInvoiceRequired: true,
      );
    }

    // No RCM applicable.
    return const RcmResult(
      isRcmApplicable: false,
      rcmSection: RcmSection.none,
      serviceCategory: null,
      reason: 'RCM not applicable — registered supplier, non-notified service',
      selfInvoiceRequired: false,
    );
  }

  /// Returns the list of notified service categories under Section 9(3).
  static List<String> getNotifiedServices() {
    return _notifiedServices.map((s) => s.category).toList();
  }
}
