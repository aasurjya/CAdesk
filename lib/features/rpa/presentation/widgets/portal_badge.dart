import 'package:flutter/material.dart';

import 'package:ca_app/features/rpa/domain/models/automation_task.dart';

/// Small colored chip indicating which government portal a task targets.
///
/// Color scheme: TRACES = blue, GSTN = green, MCA = orange,
/// ITD / EPFO = grey fallback.
class PortalBadge extends StatelessWidget {
  const PortalBadge({required this.portal, super.key});

  final AutomationPortal portal;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor(portal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static (String, Color) _labelAndColor(AutomationPortal portal) {
    switch (portal) {
      case AutomationPortal.traces:
        return ('TRACES', const Color(0xFF1565C0));
      case AutomationPortal.gstn:
        return ('GSTN', const Color(0xFF2E7D32));
      case AutomationPortal.mca:
        return ('MCA', const Color(0xFFE65100));
      case AutomationPortal.itd:
        return ('ITD', const Color(0xFF6A1B9A));
      case AutomationPortal.epfo:
        return ('EPFO', const Color(0xFF00695C));
    }
  }
}
