import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/data/providers/client_portal_providers.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/messages_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/documents_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/queries_tab.dart';
import 'package:ca_app/features/client_portal/presentation/tabs/notifications_tab.dart';

/// Main screen for the Client Portal & Communication module.
/// Provides tabbed navigation: Messages, Documents, Queries, Notifications.
class ClientPortalScreen extends ConsumerWidget {
  const ClientPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client Portal',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Communication and client-facing workflows',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(62),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: TabBar(
                  isScrollable: false,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: [
                    const Tab(icon: Icon(Icons.chat_bubble_outline, size: 20), text: 'Messages'),
                    const Tab(
                      icon: Icon(Icons.folder_shared_outlined, size: 20),
                      text: 'Documents',
                    ),
                    const Tab(
                      icon: Icon(Icons.support_agent_outlined, size: 20),
                      text: 'Queries',
                    ),
                    Tab(
                      icon: Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text(
                          '$unreadCount',
                          style: const TextStyle(fontSize: 9),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 20),
                      ),
                      text: 'Alerts',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              MessagesTab(),
              DocumentsTab(),
              QueriesTab(),
              NotificationsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
