import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/tasks/data/datasources/task_local_source.dart';
import 'package:ca_app/features/tasks/data/datasources/task_remote_source.dart';
import 'package:ca_app/features/tasks/data/repositories/mock_task_repository.dart';
import 'package:ca_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:ca_app/features/tasks/domain/repositories/task_repository.dart';

final taskRemoteSourceProvider = Provider<TaskRemoteSource>((ref) {
  return TaskRemoteSource(Supabase.instance.client);
});

final taskLocalSourceProvider = Provider<TaskLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskLocalSource(db);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('tasks_real_repo') ?? false;

  if (!useReal) {
    return MockTaskRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return TaskRepositoryImpl(
    remote: ref.watch(taskRemoteSourceProvider),
    local: ref.watch(taskLocalSourceProvider),
    firmId: firmId,
  );
});
