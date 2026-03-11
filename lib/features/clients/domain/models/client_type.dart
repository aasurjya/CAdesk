import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

enum ClientType {
  individual('Individual'),
  huf('HUF'),
  firm('Partnership Firm'),
  llp('LLP'),
  company('Private Limited'),
  publicLimited('Public Limited'),
  trust('Trust'),
  aop('AOP/BOI');

  const ClientType(this.label);

  final String label;

  Color get color {
    switch (this) {
      case ClientType.individual:
        return AppColors.primary;
      case ClientType.huf:
        return AppColors.secondary;
      case ClientType.firm:
        return AppColors.accent;
      case ClientType.llp:
        return const Color(0xFF6B21A8);
      case ClientType.company:
        return AppColors.success;
      case ClientType.publicLimited:
        return const Color(0xFF0369A1);
      case ClientType.trust:
        return const Color(0xFF9D174D);
      case ClientType.aop:
        return AppColors.neutral600;
    }
  }

  IconData get icon {
    switch (this) {
      case ClientType.individual:
        return Icons.person;
      case ClientType.huf:
        return Icons.family_restroom;
      case ClientType.firm:
        return Icons.handshake;
      case ClientType.llp:
        return Icons.group_work;
      case ClientType.company:
        return Icons.business;
      case ClientType.publicLimited:
        return Icons.corporate_fare;
      case ClientType.trust:
        return Icons.account_balance;
      case ClientType.aop:
        return Icons.groups;
    }
  }
}
