import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum ProposalStatus {
  draft(
    'Draft',
    AppColors.neutral400,
    Icons.edit_note_rounded,
  ),
  sent(
    'Sent',
    AppColors.secondary,
    Icons.send_rounded,
  ),
  accepted(
    'Accepted',
    AppColors.success,
    Icons.check_circle_rounded,
  ),
  rejected(
    'Rejected',
    AppColors.error,
    Icons.cancel_rounded,
  );

  const ProposalStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable model representing an advisory proposal sent to a client.
class AdvisoryProposal {
  const AdvisoryProposal({
    required this.id,
    required this.opportunityId,
    required this.clientName,
    required this.proposedFee,
    required this.scope,
    required this.sentAt,
    required this.status,
    this.acceptedAt,
  });

  final String id;
  final String opportunityId;
  final String clientName;
  final double proposedFee;
  final String scope;
  final DateTime sentAt;
  final ProposalStatus status;
  final DateTime? acceptedAt;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Fee formatted as Indian currency string (e.g. "₹1.5L").
  String get formattedFee {
    if (proposedFee >= 100000) {
      final lakhs = proposedFee / 100000;
      final formatted = lakhs == lakhs.truncateToDouble()
          ? '${lakhs.toInt()}L'
          : '${lakhs.toStringAsFixed(1)}L';
      return '₹$formatted';
    }
    if (proposedFee >= 1000) {
      final thousands = proposedFee / 1000;
      final formatted = thousands == thousands.truncateToDouble()
          ? '${thousands.toInt()}K'
          : '${thousands.toStringAsFixed(1)}K';
      return '₹$formatted';
    }
    return '₹${proposedFee.toInt()}';
  }

  /// Human-readable relative time since the proposal was sent.
  String get timeAgo {
    final now = DateTime(2026, 3, 11);
    final diff = now.difference(sentAt);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AdvisoryProposal copyWith({
    String? id,
    String? opportunityId,
    String? clientName,
    double? proposedFee,
    String? scope,
    DateTime? sentAt,
    ProposalStatus? status,
    DateTime? acceptedAt,
  }) {
    return AdvisoryProposal(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      clientName: clientName ?? this.clientName,
      proposedFee: proposedFee ?? this.proposedFee,
      scope: scope ?? this.scope,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
