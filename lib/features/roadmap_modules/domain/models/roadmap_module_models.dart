import 'package:flutter/material.dart';

enum RoadmapItemStatus { onTrack, planned, atRisk, blocked, completed }

enum RoadmapMetricTrend { up, steady, down }

class RoadmapWorkItem {
  const RoadmapWorkItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.owner,
    required this.dueLabel,
    required this.status,
    required this.progress,
    required this.tags,
  });

  final String id;
  final String title;
  final String subtitle;
  final String owner;
  final String dueLabel;
  final RoadmapItemStatus status;
  final double progress;
  final List<String> tags;
}

class RoadmapAutomation {
  const RoadmapAutomation({
    required this.id,
    required this.title,
    required this.description,
    required this.trigger,
    required this.outcome,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final String trigger;
  final String outcome;
  final bool enabled;

  RoadmapAutomation copyWith({bool? enabled}) {
    return RoadmapAutomation(
      id: id,
      title: title,
      description: description,
      trigger: trigger,
      outcome: outcome,
      enabled: enabled ?? this.enabled,
    );
  }
}

class RoadmapMetric {
  const RoadmapMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.trend,
  });

  final String label;
  final String value;
  final String delta;
  final RoadmapMetricTrend trend;
}

class RoadmapModuleSummary {
  const RoadmapModuleSummary({
    required this.totalItems,
    required this.activeItems,
    required this.atRiskItems,
    required this.enabledAutomations,
  });

  final int totalItems;
  final int activeItems;
  final int atRiskItems;
  final int enabledAutomations;
}

class RoadmapModuleDefinition {
  const RoadmapModuleDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.heroTitle,
    required this.heroDescription,
    required this.icon,
    required this.accentColor,
    required this.workItems,
    required this.automations,
    required this.metrics,
    required this.quickWins,
  });

  final String id;
  final String title;
  final String subtitle;
  final String heroTitle;
  final String heroDescription;
  final IconData icon;
  final Color accentColor;
  final List<RoadmapWorkItem> workItems;
  final List<RoadmapAutomation> automations;
  final List<RoadmapMetric> metrics;
  final List<String> quickWins;

  RoadmapModuleDefinition copyWith({
    List<RoadmapWorkItem>? workItems,
    List<RoadmapAutomation>? automations,
    List<RoadmapMetric>? metrics,
    List<String>? quickWins,
  }) {
    return RoadmapModuleDefinition(
      id: id,
      title: title,
      subtitle: subtitle,
      heroTitle: heroTitle,
      heroDescription: heroDescription,
      icon: icon,
      accentColor: accentColor,
      workItems: workItems ?? this.workItems,
      automations: automations ?? this.automations,
      metrics: metrics ?? this.metrics,
      quickWins: quickWins ?? this.quickWins,
    );
  }
}
