import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Platform for a virtual hearing.
enum HearingPlatform {
  nfacPortal('NfAC Portal'),
  videoConference('Video Conference');

  const HearingPlatform(this.label);
  final String label;
}

/// Status of a hearing schedule.
enum HearingStatus {
  scheduled('Scheduled'),
  completed('Completed'),
  adjourned('Adjourned'),
  cancelled('Cancelled');

  const HearingStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case HearingStatus.scheduled:
        return AppColors.primaryVariant;
      case HearingStatus.completed:
        return AppColors.success;
      case HearingStatus.adjourned:
        return AppColors.warning;
      case HearingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case HearingStatus.scheduled:
        return Icons.event;
      case HearingStatus.completed:
        return Icons.check_circle;
      case HearingStatus.adjourned:
        return Icons.pause_circle_outline;
      case HearingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

/// Immutable model representing a virtual hearing schedule.
class HearingSchedule {
  const HearingSchedule({
    required this.id,
    required this.proceedingId,
    required this.clientName,
    required this.hearingDate,
    required this.hearingTime,
    required this.platform,
    required this.agenda,
    required this.documentsToSubmit,
    required this.representativeName,
    required this.status,
    this.notes,
  });

  final String id;
  final String proceedingId;
  final String clientName;
  final DateTime hearingDate;
  final String hearingTime;
  final HearingPlatform platform;
  final String agenda;
  final List<String> documentsToSubmit;
  final String representativeName;
  final HearingStatus status;
  final String? notes;

  /// Days until the hearing date.
  int get daysUntilHearing {
    return hearingDate.difference(DateTime.now()).inDays;
  }

  /// Whether the hearing is upcoming (within 3 days).
  bool get isImminent => daysUntilHearing <= 3 && daysUntilHearing >= 0;

  HearingSchedule copyWith({
    String? id,
    String? proceedingId,
    String? clientName,
    DateTime? hearingDate,
    String? hearingTime,
    HearingPlatform? platform,
    String? agenda,
    List<String>? documentsToSubmit,
    String? representativeName,
    HearingStatus? status,
    String? notes,
  }) {
    return HearingSchedule(
      id: id ?? this.id,
      proceedingId: proceedingId ?? this.proceedingId,
      clientName: clientName ?? this.clientName,
      hearingDate: hearingDate ?? this.hearingDate,
      hearingTime: hearingTime ?? this.hearingTime,
      platform: platform ?? this.platform,
      agenda: agenda ?? this.agenda,
      documentsToSubmit: documentsToSubmit ?? this.documentsToSubmit,
      representativeName: representativeName ?? this.representativeName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HearingSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
