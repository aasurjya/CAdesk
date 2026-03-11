import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';

/// A list tile displaying a single user session with presence indicator.
class UserSessionTile extends StatelessWidget {
  const UserSessionTile({super.key, required this.session});

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading: CircleAvatar with presence ring
              _PresenceAvatar(session: session),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: name and presence chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.userName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PresenceChip(presence: session.presence),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 2: role and device
                    Text(
                      '${session.role.label} • ${session.device}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),

                    // Row 3: current module and location (if available)
                    if (session.currentModule != null ||
                        session.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (session.currentModule != null) ...[
                            Icon(
                              Icons.grid_view_rounded,
                              size: 12,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.currentModule!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (session.currentModule != null &&
                              session.location != null)
                            const SizedBox(width: 8),
                          if (session.location != null) ...[
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(session.lastActivity),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _PresenceAvatar extends StatelessWidget {
  const _PresenceAvatar({required this.session});

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    final initial = session.userName.isNotEmpty
        ? session.userName[0].toUpperCase()
        : '?';
    final ringColor = session.presence.color;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.5),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _PresenceChip extends StatelessWidget {
  const _PresenceChip({required this.presence});

  final PresenceStatus presence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: presence.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: presence.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            presence.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: presence.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
