/// A single revenue record linked to a client and service type.
class RevenueData {
  const RevenueData({
    required this.clientId,
    required this.clientName,
    required this.serviceType,
    required this.amount,
    required this.month,
    required this.year,
  });

  final String clientId;
  final String clientName;
  final String serviceType;
  final double amount;
  final int month;
  final int year;

  /// Human-readable period label (e.g. "Jan 2026").
  String get periodLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  RevenueData copyWith({
    String? clientId,
    String? clientName,
    String? serviceType,
    double? amount,
    int? month,
    int? year,
  }) {
    return RevenueData(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      serviceType: serviceType ?? this.serviceType,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevenueData &&
        other.clientId == clientId &&
        other.serviceType == serviceType &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(clientId, serviceType, month, year);
}
