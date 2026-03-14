import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Bottom sheet for selecting the client, portal, and return type to
/// initiate a new auto-submission job.
///
/// Shows a simple form; the caller handles the actual job creation.
class PortalLoginSheet extends StatefulWidget {
  const PortalLoginSheet({super.key, required this.onSubmit});

  /// Called with the selected values when the user taps "Start Submission".
  final void Function({
    required String clientId,
    required String clientName,
    required PortalType portalType,
    required String returnType,
  })
  onSubmit;

  /// Opens the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required void Function({
      required String clientId,
      required String clientName,
      required PortalType portalType,
      required String returnType,
    })
    onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PortalLoginSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<PortalLoginSheet> createState() => _PortalLoginSheetState();
}

class _PortalLoginSheetState extends State<PortalLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientIdController = TextEditingController();

  PortalType _selectedPortal = PortalType.itd;
  String _selectedReturnType = 'ITR-1';

  static const Map<PortalType, List<String>> _returnTypes = {
    PortalType.itd: ['ITR-1', 'ITR-2', 'ITR-3', 'ITR-4', 'ITR-5', 'ITR-6'],
    PortalType.gstn: ['GSTR-1', 'GSTR-3B', 'GSTR-9', 'GSTR-9C'],
    PortalType.traces: ['24Q', '26Q', '27Q', '27EQ'],
    PortalType.mca: ['MGT-7', 'AOC-4', 'INC-20A', 'DIR-3 KYC'],
    PortalType.epfo: ['ECR'],
  };

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        clientId: _clientIdController.text.trim(),
        clientName: _clientNameController.text.trim(),
        portalType: _selectedPortal,
        returnType: _selectedReturnType,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'New Submission',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 20),

            // Client name
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                hintText: 'e.g. Ravi Kumar Sharma',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Client ID
            TextFormField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID / PAN',
                hintText: 'e.g. ABCDE1234F',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Portal selector
            DropdownButtonFormField<PortalType>(
              initialValue: _selectedPortal,
              decoration: const InputDecoration(
                labelText: 'Portal',
                prefixIcon: Icon(Icons.language_rounded),
              ),
              items: PortalType.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedPortal = v;
                    _selectedReturnType = _returnTypes[v]!.first;
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // Return type selector
            DropdownButtonFormField<String>(
              initialValue: _selectedReturnType,
              decoration: const InputDecoration(
                labelText: 'Return Type',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              items: (_returnTypes[_selectedPortal] ?? [])
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedReturnType = v);
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Start Submission'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
