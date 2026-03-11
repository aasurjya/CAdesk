import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';

/// Mock client list for the timer start form.
const _kClients = <String>[
  'Rajesh Kumar Sharma',
  'ABC Infra Pvt Ltd',
  'Mehta & Sons',
  'TechVista Solutions LLP',
  'Bharat Electronics Ltd',
  'Deepak Patel',
  'GreenLeaf Organics LLP',
  'Vikram Singh Rathore',
  'Priya Mehta',
  'Anil Gupta HUF',
  'Sharma Charitable Trust',
  'Hindustan Traders AOP',
  'Internal',
];

const double _kDefaultBillingRate = 2000;

/// Bottom sheet for starting a new timer session.
class StartTimerSheet extends ConsumerStatefulWidget {
  const StartTimerSheet({super.key});

  @override
  ConsumerState<StartTimerSheet> createState() => _StartTimerSheetState();
}

class _StartTimerSheetState extends ConsumerState<StartTimerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _rateController =
      TextEditingController(text: _kDefaultBillingRate.toStringAsFixed(0));

  String _selectedClient = _kClients.first;

  @override
  void dispose() {
    _taskController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start Timer',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 20),
            // Client selector
            DropdownButtonFormField<String>(
              initialValue: _selectedClient,
              decoration: const InputDecoration(
                labelText: 'Client',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
              items: _kClients.map((client) {
                return DropdownMenuItem<String>(
                  value: client,
                  child: Text(
                    client,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedClient = value);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a client';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Task description
            TextFormField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                hintText: 'e.g. GST-3B filing for Mar 2026',
                prefixIcon: Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Billing rate
            TextFormField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Billing Rate (₹/hr)',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a billing rate';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid rate (0 for non-billable)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Start button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Timer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text.trim()) ??
        _kDefaultBillingRate;

    ref.read(activeTimerProvider.notifier).start(
          clientName: _selectedClient,
          taskDescription: _taskController.text.trim(),
          billingRate: rate,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
