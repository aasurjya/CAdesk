import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data & providers for the time entry form
// ---------------------------------------------------------------------------

final _mockClients = [
  'Rajesh Sharma',
  'Priya Patel',
  'Arjun Enterprises Pvt Ltd',
  'Meera Textiles LLP',
  'Vikram & Associates',
];

final _mockEngagements = [
  'ITR Filing AY 2025-26',
  'GST Return - March 2026',
  'TDS Quarterly Return',
  'Audit FY 2025-26',
  'ROC Annual Filing',
  'Advisory - Tax Planning',
];

/// Holds the ephemeral state for a single time entry form.
class TimeEntryFormState {
  const TimeEntryFormState({
    this.client,
    this.engagement,
    this.date,
    this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.isBillable = true,
    this.description = '',
    this.ratePerHour = 2500,
    this.isTimerRunning = false,
    this.timerElapsedSeconds = 0,
  });

  final String? client;
  final String? engagement;
  final DateTime? date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int durationMinutes;
  final bool isBillable;
  final String description;
  final double ratePerHour;
  final bool isTimerRunning;
  final int timerElapsedSeconds;

  TimeEntryFormState copyWith({
    String? client,
    String? engagement,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? durationMinutes,
    bool? isBillable,
    String? description,
    double? ratePerHour,
    bool? isTimerRunning,
    int? timerElapsedSeconds,
  }) {
    return TimeEntryFormState(
      client: client ?? this.client,
      engagement: engagement ?? this.engagement,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isBillable: isBillable ?? this.isBillable,
      description: description ?? this.description,
      ratePerHour: ratePerHour ?? this.ratePerHour,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      timerElapsedSeconds: timerElapsedSeconds ?? this.timerElapsedSeconds,
    );
  }
}

/// New time entry form with client/engagement selectors, date/time pickers,
/// billable toggle, description, auto-filled rate, and a live timer.
class TimeEntryScreen extends ConsumerStatefulWidget {
  const TimeEntryScreen({super.key});

  @override
  ConsumerState<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends ConsumerState<TimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  TimeEntryFormState _form = TimeEntryFormState(date: DateTime.now());
  Timer? _timer;

  @override
  void dispose() {
    _descriptionController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_form.isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _form = _form.copyWith(
          isTimerRunning: false,
          durationMinutes: (_form.timerElapsedSeconds / 60).ceil(),
        );
      });
    } else {
      setState(() {
        _form = _form.copyWith(isTimerRunning: true);
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _form = _form.copyWith(
            timerElapsedSeconds: _form.timerElapsedSeconds + 1,
          );
        });
      });
    }
  }

  String _formatTimer(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;
    if (_form.client == null) {
      _showSnackBar('Please select a client');
      return;
    }
    _timer?.cancel();
    _showSnackBar('Time entry saved');
    if (context.mounted) context.pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Time Entry'),
        actions: [TextButton(onPressed: _saveEntry, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Timer button
            _TimerCard(
              elapsed: _form.timerElapsedSeconds,
              isRunning: _form.isTimerRunning,
              formattedTime: _formatTimer(_form.timerElapsedSeconds),
              onToggle: _toggleTimer,
            ),
            const SizedBox(height: 20),

            // Client selector
            _SectionLabel(label: 'Client', icon: Icons.person_outline_rounded),
            const SizedBox(height: 8),
            _DropdownField(
              value: _form.client,
              items: _mockClients,
              hint: 'Select client',
              onChanged: (value) =>
                  setState(() => _form = _form.copyWith(client: value)),
            ),
            const SizedBox(height: 16),

            // Engagement selector
            _SectionLabel(
              label: 'Engagement / Task',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 8),
            _DropdownField(
              value: _form.engagement,
              items: _mockEngagements,
              hint: 'Select engagement',
              onChanged: (value) =>
                  setState(() => _form = _form.copyWith(engagement: value)),
            ),
            const SizedBox(height: 16),

            // Date & time row
            _SectionLabel(
              label: 'Date & Time',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    date: _form.date ?? DateTime.now(),
                    onChanged: (d) =>
                        setState(() => _form = _form.copyWith(date: d)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerField(
                    label: 'Start',
                    time: _form.startTime,
                    onChanged: (t) =>
                        setState(() => _form = _form.copyWith(startTime: t)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerField(
                    label: 'End',
                    time: _form.endTime,
                    onChanged: (t) =>
                        setState(() => _form = _form.copyWith(endTime: t)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duration (manual)
            _SectionLabel(
              label: 'Duration (minutes)',
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _form.durationMinutes > 0
                  ? '${_form.durationMinutes}'
                  : '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 90',
                suffixText: 'min',
              ),
              onChanged: (value) {
                final mins = int.tryParse(value) ?? 0;
                setState(() => _form = _form.copyWith(durationMinutes: mins));
              },
            ),
            const SizedBox(height: 16),

            // Billable toggle + rate
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Billable',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: _form.isBillable,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) => setState(
                      () => _form = _form.copyWith(isBillable: value),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: '${_form.ratePerHour.toInt()}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '\u20B9 ',
                      suffixText: '/hr',
                      labelText: 'Rate',
                    ),
                    onChanged: (value) {
                      final rate = double.tryParse(value) ?? 0;
                      setState(() => _form = _form.copyWith(ratePerHour: rate));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _SectionLabel(
              label: 'Description / Notes',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What did you work on?',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  setState(() => _form = _form.copyWith(description: value)),
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save Time Entry'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer card
// ---------------------------------------------------------------------------

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.elapsed,
    required this.isRunning,
    required this.formattedTime,
    required this.onToggle,
  });

  final int elapsed;
  final bool isRunning;
  final String formattedTime;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isRunning ? AppColors.success : AppColors.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              formattedTime,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onToggle,
              icon: Icon(
                isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(isRunning ? 'Stop Timer' : 'Start Timer'),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(180, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(hintText: hint),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final display =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date'),
        child: Text(display),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = time != null ? time!.format(context) : '--:--';

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(display),
      ),
    );
  }
}
