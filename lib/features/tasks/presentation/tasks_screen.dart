import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tasks/presentation/tasks_list_screen.dart';

/// Shell widget that the router references.
/// Delegates entirely to [TasksListScreen].
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TasksListScreen();
  }
}
