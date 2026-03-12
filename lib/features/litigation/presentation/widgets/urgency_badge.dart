import 'package:flutter/material.dart';

import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';

/// Small color-coded chip indicating urgency level.
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({required this.urgency, super.key});

  final UrgencyLevel urgency;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _style(urgency);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static (String, Color, Color) _style(UrgencyLevel level) {
    return switch (level) {
      UrgencyLevel.critical => ('CRITICAL', const Color(0xFFFFEBEE), const Color(0xFFB71C1C)),
      UrgencyLevel.high => ('HIGH', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      UrgencyLevel.medium => ('MEDIUM', const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
      UrgencyLevel.low => ('LOW', const Color(0xFFE8F5E9), const Color(0xFF1B5E20)),
    };
  }
}
