import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/ai/genui/models/ui_directive.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';

/// Provides AI-generated insight cards for the dashboard.
///
/// When `ai_genui_enabled` is off, returns static insights.
final aiInsightsProvider = FutureProvider<List<UiDirective>>((ref) async {
  final flags = ref.watch(featureFlagProvider).asData?.value;
  final genUiEnabled = flags?.isEnabled('ai_genui_enabled') ?? false;

  if (!genUiEnabled) {
    return _staticInsights();
  }

  // TODO: Call SafeAiGateway to generate dynamic insights
  return _staticInsights();
});

List<UiDirective> _staticInsights() {
  return [
    UiDirective(
      type: DirectiveType.deadlineAlert,
      title: 'TDS Deposit Due',
      body:
          'TDS for February 2026 must be deposited by March 7. '
          '3 clients have pending challans.',
      priority: 2,
      actionRoute: '/tds',
    ),
    UiDirective(
      type: DirectiveType.complianceStatus,
      title: 'GST Return Status',
      body:
          'GSTR-3B for February is due on March 20. '
          '5 clients have filed, 8 pending.',
      priority: 1,
      actionRoute: '/gst',
    ),
    UiDirective(
      type: DirectiveType.insightCard,
      title: 'Advance Tax Reminder',
      body:
          'March 15 is the final installment for advance tax (100%). '
          'Review client portfolios for shortfall.',
      priority: 1,
      actionRoute: '/compliance',
    ),
  ];
}
