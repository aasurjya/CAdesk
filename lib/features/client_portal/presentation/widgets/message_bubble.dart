import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_message.dart';

/// Chat bubble widget styled differently for client, staff, and system messages.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final PortalMessage message;

  @override
  Widget build(BuildContext context) {
    final isClient = message.senderType == SenderType.client;
    final isSystem = message.senderType == SenderType.system;
    final theme = Theme.of(context);

    if (isSystem) {
      return _SystemBubble(message: message);
    }

    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isClient ? AppColors.primary.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isClient ? 16 : 4),
            bottomRight: Radius.circular(isClient ? 4 : 16),
          ),
          border: Border.all(
            color: isClient
                ? AppColors.primary.withAlpha(40)
                : AppColors.neutral200,
          ),
        ),
        child: Column(
          crossAxisAlignment: isClient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isClient ? AppColors.primary : AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral900,
              ),
            ),
            if (message.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...message.attachments.map(
                (attachment) => _AttachmentChip(fileName: attachment),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('d MMM, h:mm a').format(message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                  ),
                ),
                if (!message.isRead && !isClient) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  const _SystemBubble({required this.message});

  final PortalMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_file, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
