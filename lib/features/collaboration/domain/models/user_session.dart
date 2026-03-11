import 'package:flutter/material.dart';

enum UserRole {
  partner('Partner'),
  senior('Senior'),
  staff('Staff'),
  outsourced('Outsourced'),
  admin('Admin');

  const UserRole(this.label);
  final String label;
}

enum PresenceStatus {
  online('Online', Color(0xFF1A7A3A)),
  idle('Idle', Color(0xFFD4890E)),
  offline('Offline', Color(0xFF718096)),
  doNotDisturb('DND', Color(0xFFC62828));

  const PresenceStatus(this.label, this.color);
  final String label;
  final Color color;
}

class UserSession {
  const UserSession({
    required this.id,
    required this.userName,
    required this.role,
    required this.device,
    required this.presence,
    required this.lastActivity,
    required this.loginTime,
    this.location,
    this.currentModule,
    this.ipAddress,
  });

  final String id;
  final String userName;
  final UserRole role;
  final String device;
  final PresenceStatus presence;
  final DateTime lastActivity;
  final DateTime loginTime;
  final String? location;
  final String? currentModule;
  final String? ipAddress;

  bool get isOnline =>
      presence == PresenceStatus.online || presence == PresenceStatus.idle;
}
