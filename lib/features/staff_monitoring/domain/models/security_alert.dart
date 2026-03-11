enum AlertType {
  unusualLogin('Unusual Login'),
  offHoursAccess('Off-Hours Access'),
  sensitiveDownload('Sensitive Download'),
  multipleFailedLogins('Multiple Failed Logins'),
  locationChange('Location Change');

  const AlertType(this.label);

  final String label;
}

enum AlertSeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const AlertSeverity(this.label);

  final String label;
}

class SecurityAlert {
  const SecurityAlert({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.timestamp,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
  });

  final String id;
  final String staffId;
  final String staffName;
  final AlertType alertType;
  final AlertSeverity severity;
  final String description;
  final DateTime timestamp;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  SecurityAlert copyWith({
    String? id,
    String? staffId,
    String? staffName,
    AlertType? alertType,
    AlertSeverity? severity,
    String? description,
    DateTime? timestamp,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return SecurityAlert(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityAlert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
