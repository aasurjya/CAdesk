import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/compliance/presentation/compliance_calendar_screen.dart';

/// Shell widget that the router references.
/// Delegates entirely to [ComplianceCalendarScreen].
class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ComplianceCalendarScreen();
  }
}
