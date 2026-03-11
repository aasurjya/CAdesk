import 'package:flutter/material.dart';

enum LeadSource {
  referral('Referral', Icons.people_rounded),
  website('Website', Icons.language_rounded),
  whatsApp('WhatsApp', Icons.chat_rounded),
  walkin('Walk-in', Icons.store_rounded),
  socialMedia('Social Media', Icons.thumb_up_rounded),
  campaign('Campaign', Icons.campaign_rounded),
  partner('Partner', Icons.handshake_rounded);

  const LeadSource(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum LeadStage {
  newLead('New Lead', Color(0xFF718096), Icons.fiber_new_rounded),
  contacted('Contacted', Color(0xFF0D7C7C), Icons.phone_in_talk_rounded),
  qualified('Qualified', Color(0xFF1B3A5C), Icons.verified_rounded),
  proposalSent('Proposal Sent', Color(0xFFE8890C), Icons.description_rounded),
  negotiation('Negotiation', Color(0xFFD4890E), Icons.handshake_rounded),
  won('Won', Color(0xFF1A7A3A), Icons.emoji_events_rounded),
  lost('Lost', Color(0xFFC62828), Icons.cancel_rounded);

  const LeadStage(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class Lead {
  const Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.source,
    required this.stage,
    required this.estimatedValue,
    required this.assignedTo,
    required this.createdAt,
    this.lastContactedAt,
    required this.notes,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final LeadSource source;
  final LeadStage stage;
  final double estimatedValue;
  final String assignedTo;
  final DateTime createdAt;
  final DateTime? lastContactedAt;
  final String notes;

  /// Value formatted as ₹X.XL or ₹X,XXX.
  String get formattedValue {
    if (estimatedValue >= 100000) {
      final lakhs = estimatedValue / 100000;
      return '₹${lakhs.toStringAsFixed(1)}L';
    }
    return '₹${estimatedValue.toStringAsFixed(0)}';
  }

  /// Human-readable time since the lead was created.
  String get timeAgo {
    final now = DateTime(2026, 3, 11);
    final diff = now.difference(createdAt);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months mo ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  /// Days since last contact, or null if never contacted.
  int? get daysSinceContact {
    if (lastContactedAt == null) return null;
    final now = DateTime(2026, 3, 11);
    return now.difference(lastContactedAt!).inDays;
  }

  Lead copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    LeadSource? source,
    LeadStage? stage,
    double? estimatedValue,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? lastContactedAt,
    String? notes,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      stage: stage ?? this.stage,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      notes: notes ?? this.notes,
    );
  }
}
