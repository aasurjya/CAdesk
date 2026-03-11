import 'package:flutter/material.dart';

enum GrowthOpportunityType {
  advisory('Advisory'),
  campaign('Campaign'),
  nri('NRI Desk'),
  cfoRetainer('CFO Retainer'),
  verticalService('Vertical Service');

  const GrowthOpportunityType(this.label);

  final String label;
}

enum GrowthOpportunityStage {
  identified('Identified', Color(0xFF1565C0)),
  proposalSent('Proposal Sent', Color(0xFF6A1B9A)),
  inDiscussion('In Discussion', Color(0xFFEF6C00)),
  won('Won', Color(0xFF1A7A3A));

  const GrowthOpportunityStage(this.label, this.color);

  final String label;
  final Color color;
}

class GrowthOpportunity {
  const GrowthOpportunity({
    required this.id,
    required this.clientName,
    required this.title,
    required this.description,
    required this.type,
    required this.stage,
    required this.estimatedFee,
    required this.owner,
    required this.nextAction,
    required this.nextActionDue,
    required this.conversionProbability,
  });

  final String id;
  final String clientName;
  final String title;
  final String description;
  final GrowthOpportunityType type;
  final GrowthOpportunityStage stage;
  final double estimatedFee;
  final String owner;
  final String nextAction;
  final DateTime nextActionDue;
  final double conversionProbability;

  GrowthOpportunity copyWith({
    String? id,
    String? clientName,
    String? title,
    String? description,
    GrowthOpportunityType? type,
    GrowthOpportunityStage? stage,
    double? estimatedFee,
    String? owner,
    String? nextAction,
    DateTime? nextActionDue,
    double? conversionProbability,
  }) {
    return GrowthOpportunity(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      owner: owner ?? this.owner,
      nextAction: nextAction ?? this.nextAction,
      nextActionDue: nextActionDue ?? this.nextActionDue,
      conversionProbability:
          conversionProbability ?? this.conversionProbability,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthOpportunity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
