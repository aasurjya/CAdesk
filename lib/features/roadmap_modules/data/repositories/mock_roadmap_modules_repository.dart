import 'package:flutter/material.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/roadmap_modules/domain/models/roadmap_module_models.dart';
import 'package:ca_app/features/roadmap_modules/domain/repositories/roadmap_modules_repository.dart';

/// In-memory mock implementation of [RoadmapModulesRepository].
///
/// Seeded with sample roadmap data for development and testing.
class MockRoadmapModulesRepository implements RoadmapModulesRepository {
  static final List<RoadmapModuleDefinition> _seed = [
    const RoadmapModuleDefinition(
      id: 'gst',
      title: 'GST Module',
      subtitle: 'Returns & Reconciliation',
      heroTitle: 'Complete GST Compliance',
      heroDescription: 'File GSTR-1, GSTR-3B, GSTR-9 and reconcile ITC.',
      icon: Icons.receipt_long_rounded,
      accentColor: AppColors.primary,
      workItems: [
        RoadmapWorkItem(
          id: 'gst-w-001',
          title: 'GSTR-1 monthly filing',
          subtitle: 'File outward supplies return',
          owner: 'Staff A',
          dueLabel: 'Q1 FY27',
          status: RoadmapItemStatus.onTrack,
          progress: 0.8,
          tags: ['GST', 'Filing'],
        ),
      ],
      automations: [
        RoadmapAutomation(
          id: 'gst-a-001',
          title: 'Auto-reconcile GSTR-2A',
          description: 'Reconcile purchase register against GSTR-2A nightly.',
          trigger: 'Nightly at 2 AM',
          outcome: 'Mismatch report emailed to CA',
          enabled: true,
        ),
      ],
      metrics: [
        RoadmapMetric(
          label: 'Filings this month',
          value: '24',
          delta: '+4',
          trend: RoadmapMetricTrend.up,
        ),
      ],
      quickWins: ['Enable auto-draft GSTR-3B from GSTR-1 data'],
    ),
    const RoadmapModuleDefinition(
      id: 'tds',
      title: 'TDS Module',
      subtitle: 'Deduction & Returns',
      heroTitle: 'TDS Compliance Automation',
      heroDescription: 'Automate TDS computation, challan and returns.',
      icon: Icons.account_balance_rounded,
      accentColor: AppColors.secondary,
      workItems: [
        RoadmapWorkItem(
          id: 'tds-w-001',
          title: '24Q quarterly return',
          subtitle: 'Salary TDS return filing',
          owner: 'Staff B',
          dueLabel: 'Q1 FY27',
          status: RoadmapItemStatus.planned,
          progress: 0.2,
          tags: ['TDS', 'Returns'],
        ),
      ],
      automations: [
        RoadmapAutomation(
          id: 'tds-a-001',
          title: 'Challan auto-match',
          description: 'Match deposited challans against TDS liability.',
          trigger: 'Daily',
          outcome: 'Short-deposit alerts',
          enabled: false,
        ),
      ],
      metrics: [
        RoadmapMetric(
          label: 'Challans verified',
          value: '18',
          delta: '+2',
          trend: RoadmapMetricTrend.steady,
        ),
      ],
      quickWins: ['Enable TRACES integration for auto-download Form 16'],
    ),
  ];

  final List<RoadmapModuleDefinition> _state = List.of(_seed);

  @override
  Future<List<RoadmapModuleDefinition>> getAllModules() async {
    return List.unmodifiable(_state);
  }

  @override
  Future<RoadmapModuleDefinition?> getModuleById(String id) async {
    try {
      return _state.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RoadmapAutomation?> toggleAutomation(
    String moduleId,
    String automationId,
  ) async {
    final moduleIdx = _state.indexWhere((m) => m.id == moduleId);
    if (moduleIdx == -1) return null;

    final module = _state[moduleIdx];
    final autoIdx = module.automations.indexWhere((a) => a.id == automationId);
    if (autoIdx == -1) return null;

    final existing = module.automations[autoIdx];
    final toggled = existing.copyWith(enabled: !existing.enabled);

    final updatedAutomations = List<RoadmapAutomation>.of(module.automations)
      ..[autoIdx] = toggled;
    _state[moduleIdx] = module.copyWith(automations: updatedAutomations);
    return toggled;
  }

  @override
  Future<RoadmapModuleSummary> getSummary() async {
    var totalItems = 0;
    var activeItems = 0;
    var atRiskItems = 0;
    var enabledAutomations = 0;

    for (final m in _state) {
      totalItems += m.workItems.length;
      activeItems += m.workItems
          .where(
            (i) =>
                i.status == RoadmapItemStatus.onTrack ||
                i.status == RoadmapItemStatus.planned,
          )
          .length;
      atRiskItems += m.workItems
          .where((i) => i.status == RoadmapItemStatus.atRisk)
          .length;
      enabledAutomations += m.automations.where((a) => a.enabled).length;
    }

    return RoadmapModuleSummary(
      totalItems: totalItems,
      activeItems: activeItems,
      atRiskItems: atRiskItems,
      enabledAutomations: enabledAutomations,
    );
  }
}
