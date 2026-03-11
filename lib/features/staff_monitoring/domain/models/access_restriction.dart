enum RestrictionType {
  website('Website'),
  time('Time'),
  fileType('File Type'),
  module('Module');

  const RestrictionType(this.label);

  final String label;
}

class AccessRestriction {
  const AccessRestriction({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.restrictionType,
    required this.value,
    required this.reason,
    required this.appliedBy,
    required this.appliedAt,
    this.isActive = true,
  });

  final String id;
  final String staffId;
  final String staffName;
  final RestrictionType restrictionType;
  final String value;
  final String reason;
  final String appliedBy;
  final DateTime appliedAt;
  final bool isActive;

  AccessRestriction copyWith({
    String? id,
    String? staffId,
    String? staffName,
    RestrictionType? restrictionType,
    String? value,
    String? reason,
    String? appliedBy,
    DateTime? appliedAt,
    bool? isActive,
  }) {
    return AccessRestriction(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      restrictionType: restrictionType ?? this.restrictionType,
      value: value ?? this.value,
      reason: reason ?? this.reason,
      appliedBy: appliedBy ?? this.appliedBy,
      appliedAt: appliedAt ?? this.appliedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessRestriction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
