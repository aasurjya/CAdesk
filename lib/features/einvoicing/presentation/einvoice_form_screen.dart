import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import '../data/providers/einvoice_form_providers.dart';
import 'widgets/einvoice_line_item_card.dart';
import 'widgets/line_item_bottom_sheet.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _documentTypes = ['Tax Invoice', 'Credit Note', 'Debit Note'];

const _transportModes = ['Road', 'Rail', 'Air', 'Ship'];

/// E-Way Bill value threshold in INR.
const double _ewayBillThreshold = 50000;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Form screen for creating or editing an e-invoice.
///
/// Covers document type selection, buyer details (with GSTIN auto-fetch),
/// line item entry, auto-computed GST, optional E-Way Bill section,
/// and save/validate/generate actions.
class EinvoiceFormScreen extends ConsumerStatefulWidget {
  const EinvoiceFormScreen({super.key, this.invoiceId});

  /// When non-null, the screen is in edit mode for an existing invoice.
  final String? invoiceId;

  @override
  ConsumerState<EinvoiceFormScreen> createState() => _EinvoiceFormScreenState();
}

class _EinvoiceFormScreenState extends ConsumerState<EinvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _gstinController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _posController = TextEditingController();

  bool get _isEditMode => widget.invoiceId != null;

  @override
  void dispose() {
    _gstinController.dispose();
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _addressController.dispose();
    _posController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(einvoiceFormDataProvider);
    final lineItems = ref.watch(einvoiceLineItemsProvider);
    final irnStatus = ref.watch(einvoiceStatusProvider);
    final theme = Theme.of(context);

    final subTotal = lineItems.fold(
      0.0,
      (sum, item) => sum + item.taxableValue,
    );
    final totalTax = lineItems.fold(
      0.0,
      (sum, item) => sum + item.cgstAmount + item.sgstAmount + item.igstAmount,
    );
    final grandTotal = subTotal + totalTax;
    final showEwayBill = grandTotal > _ewayBillThreshold;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          _isEditMode ? 'Edit E-Invoice' : 'New E-Invoice',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Document type selector
                  _DocumentTypeSection(
                    selectedType: formData.documentType,
                    onChanged: (type) {
                      ref
                          .read(einvoiceFormDataProvider.notifier)
                          .update(formData.copyWith(documentType: type));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Buyer details
                  _BuyerDetailsSection(
                    gstinController: _gstinController,
                    legalNameController: _legalNameController,
                    tradeNameController: _tradeNameController,
                    addressController: _addressController,
                    posController: _posController,
                    onGstinFetch: () => _fetchGstinDetails(),
                  ),
                  const SizedBox(height: 16),
                  // Line items header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: 'Line Items',
                      icon: Icons.list_alt_rounded,
                      trailing: TextButton.icon(
                        onPressed: () => _showAddLineItemSheet(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Line items
            if (lineItems.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: EmptyState(
                    message: 'No line items',
                    subtitle: 'Tap "Add Item" to add invoice line items.',
                    icon: Icons.playlist_add_rounded,
                    iconSize: 48,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = lineItems[index];
                  return EinvoiceLineItemCard(
                    item: item,
                    onEdit: () =>
                        _showAddLineItemSheet(context, existing: item),
                    onDelete: () {
                      ref
                          .read(einvoiceLineItemsProvider.notifier)
                          .removeItem(item.id);
                    },
                  );
                }, childCount: lineItems.length),
              ),
            // Totals
            if (lineItems.isNotEmpty)
              SliverToBoxAdapter(
                child: _TotalsSection(
                  subTotal: subTotal,
                  totalTax: totalTax,
                  grandTotal: grandTotal,
                  theme: theme,
                ),
              ),
            // E-Way Bill section
            if (showEwayBill)
              SliverToBoxAdapter(child: _EwayBillSection(formData: formData)),
            // Action buttons
            SliverToBoxAdapter(
              child: _FormActions(
                irnStatus: irnStatus,
                onSaveDraft: () => _saveDraft(),
                onValidate: () => _validate(),
                onGenerateIrn: () => _generateIrn(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _fetchGstinDetails() {
    // Simulate GSTIN auto-fetch
    _legalNameController.text = 'Sample Buyer Pvt Ltd';
    _tradeNameController.text = 'Sample Buyer';
    _addressController.text = '123 MG Road, Bengaluru';
    _posController.text = 'Karnataka (29)';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GSTIN details fetched successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddLineItemSheet(
    BuildContext context, {
    EinvoiceLineItem? existing,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LineItemBottomSheet(
        existing: existing,
        onSave: (item) {
          if (existing != null) {
            ref.read(einvoiceLineItemsProvider.notifier).updateItem(item);
          } else {
            ref.read(einvoiceLineItemsProvider.notifier).addItem(item);
          }
        },
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _validate() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(einvoiceStatusProvider.notifier).setValidating();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation passed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _generateIrn() {
    ref.read(einvoiceStatusProvider.notifier).setGenerating();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('IRN generation in progress...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document type section
// ---------------------------------------------------------------------------

class _DocumentTypeSection extends StatelessWidget {
  const _DocumentTypeSection({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FormSection(
        title: 'Document Type',
        icon: Icons.description_rounded,
        children: [
          SegmentedButton<String>(
            segments: _documentTypes
                .map(
                  (type) => ButtonSegment(
                    value: type,
                    label: Text(type, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            selected: {selectedType},
            onSelectionChanged: (values) {
              if (values.isNotEmpty) onChanged(values.first);
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withAlpha(26),
              selectedForegroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buyer details section
// ---------------------------------------------------------------------------

class _BuyerDetailsSection extends StatelessWidget {
  const _BuyerDetailsSection({
    required this.gstinController,
    required this.legalNameController,
    required this.tradeNameController,
    required this.addressController,
    required this.posController,
    required this.onGstinFetch,
  });

  final TextEditingController gstinController;
  final TextEditingController legalNameController;
  final TextEditingController tradeNameController;
  final TextEditingController addressController;
  final TextEditingController posController;
  final VoidCallback onGstinFetch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FormSection(
        title: 'Buyer Details',
        icon: Icons.business_rounded,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: gstinController,
                  decoration: const InputDecoration(
                    labelText: 'Buyer GSTIN',
                    hintText: '22AAAAA0000A1Z5',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'GSTIN is required';
                    }
                    if (value.length != 15) {
                      return 'GSTIN must be 15 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onGstinFetch,
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Auto-fetch GSTIN details',
              ),
            ],
          ),
          TextFormField(
            controller: legalNameController,
            decoration: const InputDecoration(
              labelText: 'Legal Name',
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
          ),
          TextFormField(
            controller: tradeNameController,
            decoration: const InputDecoration(
              labelText: 'Trade Name',
              prefixIcon: Icon(Icons.store_rounded),
            ),
          ),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            maxLines: 2,
          ),
          TextFormField(
            controller: posController,
            decoration: const InputDecoration(
              labelText: 'Place of Supply',
              prefixIcon: Icon(Icons.pin_drop_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Totals section
// ---------------------------------------------------------------------------

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({
    required this.subTotal,
    required this.totalTax,
    required this.grandTotal,
    required this.theme,
  });

  final double subTotal;
  final double totalTax;
  final double grandTotal;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _SummaryLine(
              label: 'Sub-Total',
              value: CurrencyUtils.formatINR(subTotal),
              theme: theme,
            ),
            _SummaryLine(
              label: 'Total Tax',
              value: CurrencyUtils.formatINR(totalTax),
              theme: theme,
            ),
            const Divider(height: 16),
            _SummaryLine(
              label: 'Grand Total',
              value: CurrencyUtils.formatINR(grandTotal),
              theme: theme,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.theme,
    this.bold = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bold ? AppColors.neutral900 : AppColors.neutral600,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bold ? AppColors.primary : AppColors.neutral900,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 15 : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E-Way Bill section
// ---------------------------------------------------------------------------

class _EwayBillSection extends ConsumerWidget {
  const _EwayBillSection({required this.formData});

  final EinvoiceFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: FormSection(
        title: 'E-Way Bill (Value > 50K)',
        icon: Icons.local_shipping_rounded,
        children: [
          DropdownButtonFormField<String>(
            initialValue: formData.transportMode.isEmpty
                ? null
                : formData.transportMode,
            decoration: const InputDecoration(
              labelText: 'Transport Mode',
              prefixIcon: Icon(Icons.directions_rounded),
            ),
            items: _transportModes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(einvoiceFormDataProvider.notifier)
                    .update(formData.copyWith(transportMode: value));
              }
            },
          ),
          TextFormField(
            initialValue: formData.vehicleNumber.isEmpty
                ? null
                : formData.vehicleNumber,
            decoration: const InputDecoration(
              labelText: 'Vehicle Number',
              hintText: 'KA01AB1234',
              prefixIcon: Icon(Icons.directions_car_rounded),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              ref
                  .read(einvoiceFormDataProvider.notifier)
                  .update(formData.copyWith(vehicleNumber: value));
            },
          ),
          TextFormField(
            initialValue: formData.distanceKm > 0
                ? '${formData.distanceKm}'
                : null,
            decoration: const InputDecoration(
              labelText: 'Distance (km)',
              prefixIcon: Icon(Icons.straighten_rounded),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              ref
                  .read(einvoiceFormDataProvider.notifier)
                  .update(
                    formData.copyWith(distanceKm: int.tryParse(value) ?? 0),
                  );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form actions
// ---------------------------------------------------------------------------

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.irnStatus,
    required this.onSaveDraft,
    required this.onValidate,
    required this.onGenerateIrn,
  });

  final EinvoiceIrnStatus irnStatus;
  final VoidCallback onSaveDraft;
  final VoidCallback onValidate;
  final VoidCallback onGenerateIrn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveDraft,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Draft'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onValidate,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Validate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: irnStatus == EinvoiceIrnStatus.generating
                ? null
                : onGenerateIrn,
            icon: const Icon(Icons.verified_rounded),
            label: Text(
              irnStatus == EinvoiceIrnStatus.generating
                  ? 'Generating...'
                  : 'Generate IRN',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
