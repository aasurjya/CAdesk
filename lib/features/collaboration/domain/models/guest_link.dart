import 'package:flutter/material.dart';

enum GuestAccessLevel {
  viewOnly('View Only'),
  download('View & Download'),
  comment('View & Comment'),
  upload('Upload & View');

  const GuestAccessLevel(this.label);
  final String label;
}

enum GuestLinkStatus {
  active('Active', Color(0xFF1A7A3A)),
  expired('Expired', Color(0xFF718096)),
  revoked('Revoked', Color(0xFFC62828));

  const GuestLinkStatus(this.label, this.color);
  final String label;
  final Color color;
}

class GuestLink {
  const GuestLink({
    required this.id,
    required this.title,
    required this.clientName,
    required this.accessLevel,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.viewCount,
    this.purpose,
    this.createdBy,
  });

  final String id;
  final String title;
  final String clientName;
  final GuestAccessLevel accessLevel;
  final GuestLinkStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final String? purpose;
  final String? createdBy;

  bool get isExpired => DateTime(2026, 3, 10).isAfter(expiresAt);
}
