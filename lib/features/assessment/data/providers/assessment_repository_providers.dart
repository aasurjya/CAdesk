import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/assessment/data/datasources/assessment_local_source.dart';
import 'package:ca_app/features/assessment/data/datasources/assessment_remote_source.dart';
import 'package:ca_app/features/assessment/data/repositories/assessment_repository_impl.dart';
import 'package:ca_app/features/assessment/data/repositories/mock_assessment_repository.dart';
import 'package:ca_app/features/assessment/domain/repositories/assessment_repository.dart';

final assessmentRemoteSourceProvider =
    Provider<AssessmentRemoteSource>((ref) {
  return AssessmentRemoteSource(Supabase.instance.client);
});

final assessmentLocalSourceProvider = Provider<AssessmentLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AssessmentLocalSource(db);
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('assessment_real_repo') ?? false;

  if (!useReal) {
    return MockAssessmentRepository();
  }

  return AssessmentRepositoryImpl(
    remote: ref.watch(assessmentRemoteSourceProvider),
    local: ref.watch(assessmentLocalSourceProvider),
  );
});
