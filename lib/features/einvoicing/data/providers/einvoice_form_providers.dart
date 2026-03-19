import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/einvoice_record.dart';

// ---------------------------------------------------------------------------
// E-Invoice form data model
// ---------------------------------------------------------------------------

/// Immutable state for the e-invoice creation/edit form.
class EinvoiceFormData {
  const EinvoiceFormData({
    this.documentType = 'Tax Invoice',
    this.buyerGstin = '',
    this.buyerLegalName = '',
    this.buyerTradeName = '',
    this.buyerAddress = '',
    this.buyerPlace = '',
    this.buyerState = '',
    this.buyerPincode = '',
    this.placeOfSupply = '',
    this.transportMode = '',
    this.vehicleNumber = '',
    this.distanceKm = 0,
  });

  final String documentType;
  final String buyerGstin;
  final String buyerLegalName;
  final String buyerTradeName;
  final String buyerAddress;
  final String buyerPlace;
  final String buyerState;
  final String buyerPincode;
  final String placeOfSupply;
  final String transportMode;
  final String vehicleNumber;
  final int distanceKm;

  EinvoiceFormData copyWith({
    String? documentType,
    String? buyerGstin,
    String? buyerLegalName,
    String? buyerTradeName,
    String? buyerAddress,
    String? buyerPlace,
    String? buyerState,
    String? buyerPincode,
    String? placeOfSupply,
    String? transportMode,
    String? vehicleNumber,
    int? distanceKm,
  }) {
    return EinvoiceFormData(
      documentType: documentType ?? this.documentType,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      buyerLegalName: buyerLegalName ?? this.buyerLegalName,
      buyerTradeName: buyerTradeName ?? this.buyerTradeName,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerPlace: buyerPlace ?? this.buyerPlace,
      buyerState: buyerState ?? this.buyerState,
      buyerPincode: buyerPincode ?? this.buyerPincode,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      transportMode: transportMode ?? this.transportMode,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

// ---------------------------------------------------------------------------
// E-Invoice line item model
// ---------------------------------------------------------------------------

/// Immutable model for a single line item in an e-invoice.
class EinvoiceLineItem {
  const EinvoiceLineItem({
    required this.id,
    this.hsnCode = '',
    this.description = '',
    this.quantity = 1,
    this.unit = 'NOS',
    this.rate = 0,
    this.discount = 0,
    this.taxableValue = 0,
    this.cgstRate = 0,
    this.sgstRate = 0,
    this.igstRate = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.igstAmount = 0,
  });

  final String id;
  final String hsnCode;
  final String description;
  final int quantity;
  final String unit;
  final double rate;
  final double discount;
  final double taxableValue;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;

  double get totalAmount => taxableValue + cgstAmount + sgstAmount + igstAmount;

  EinvoiceLineItem copyWith({
    String? id,
    String? hsnCode,
    String? description,
    int? quantity,
    String? unit,
    double? rate,
    double? discount,
    double? taxableValue,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
  }) {
    return EinvoiceLineItem(
      id: id ?? this.id,
      hsnCode: hsnCode ?? this.hsnCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      discount: discount ?? this.discount,
      taxableValue: taxableValue ?? this.taxableValue,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Form state for creating/editing an e-invoice.
final einvoiceFormDataProvider =
    NotifierProvider<EinvoiceFormDataNotifier, EinvoiceFormData>(
      EinvoiceFormDataNotifier.new,
    );

class EinvoiceFormDataNotifier extends Notifier<EinvoiceFormData> {
  @override
  EinvoiceFormData build() => const EinvoiceFormData();

  void update(EinvoiceFormData data) => state = data;
  void reset() => state = const EinvoiceFormData();
}

/// Line items for the e-invoice being created/edited.
final einvoiceLineItemsProvider =
    NotifierProvider<EinvoiceLineItemsNotifier, List<EinvoiceLineItem>>(
      EinvoiceLineItemsNotifier.new,
    );

class EinvoiceLineItemsNotifier extends Notifier<List<EinvoiceLineItem>> {
  @override
  List<EinvoiceLineItem> build() => const [];

  void addItem(EinvoiceLineItem item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateItem(EinvoiceLineItem updated) {
    state = state
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
  }

  void reset() => state = const [];
}

/// The currently selected e-invoice for the detail view.
final selectedEinvoiceProvider =
    NotifierProvider<SelectedEinvoiceNotifier, EinvoiceRecord?>(
      SelectedEinvoiceNotifier.new,
    );

class SelectedEinvoiceNotifier extends Notifier<EinvoiceRecord?> {
  @override
  EinvoiceRecord? build() => null;

  void select(EinvoiceRecord? record) => state = record;
}

/// IRN generation status for the form screen.
enum EinvoiceIrnStatus { idle, validating, generating, success, error }

final einvoiceStatusProvider =
    NotifierProvider<EinvoiceStatusNotifier, EinvoiceIrnStatus>(
      EinvoiceStatusNotifier.new,
    );

class EinvoiceStatusNotifier extends Notifier<EinvoiceIrnStatus> {
  @override
  EinvoiceIrnStatus build() => EinvoiceIrnStatus.idle;

  void setValidating() => state = EinvoiceIrnStatus.validating;
  void setGenerating() => state = EinvoiceIrnStatus.generating;
  void setSuccess() => state = EinvoiceIrnStatus.success;
  void setError() => state = EinvoiceIrnStatus.error;
  void reset() => state = EinvoiceIrnStatus.idle;
}
