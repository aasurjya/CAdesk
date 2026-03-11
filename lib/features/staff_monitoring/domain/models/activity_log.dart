enum ActivityType {
  login('Login'),
  logout('Logout'),
  fileAccess('File Access'),
  documentDownload('Document Download'),
  settingsChange('Settings Change'),
  clientView('Client View'),
  reportGenerate('Report Generate');

  const ActivityType(this.label);

  final String label;
}

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.activityType,
    required this.description,
    required this.ipAddress,
    required this.deviceName,
    required this.location,
    required this.timestamp,
    this.isAnomalous = false,
  });

  final String id;
  final String staffId;
  final String staffName;
  final ActivityType activityType;
  final String description;
  final String ipAddress;
  final String deviceName;
  final String location;
  final DateTime timestamp;
  final bool isAnomalous;

  ActivityLog copyWith({
    String? id,
    String? staffId,
    String? staffName,
    ActivityType? activityType,
    String? description,
    String? ipAddress,
    String? deviceName,
    String? location,
    DateTime? timestamp,
    bool? isAnomalous,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceName: deviceName ?? this.deviceName,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      isAnomalous: isAnomalous ?? this.isAnomalous,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
