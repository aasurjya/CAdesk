import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/compliance/data/datasources/compliance_local_source.dart';
import 'package:ca_app/features/compliance/data/datasources/compliance_remote_source.dart';
import 'package:ca_app/features/compliance/data/repositories/compliance_repository_impl.dart';
import 'package:ca_app/features/compliance/data/repositories/mock_compliance_repository.dart';
import 'package:ca_app/features/compliance/domain/repositories/compliance_repository.dart';

final complianceRemoteSourceProvider = Provider<ComplianceRemoteSource>((ref) {
  return ComplianceRemoteSource(Supabase.instance.client);
});

final complianceLocalSourceProvider = Provider<ComplianceLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ComplianceLocalSource(db);
});

final complianceRepositoryProvider = Provider<ComplianceRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('compliance_real_repo') ?? false;

  if (!useReal) {
    return MockComplianceRepository();
  }

  return ComplianceRepositoryImpl(
    remote: ref.watch(complianceRemoteSourceProvider),
    local: ref.watch(complianceLocalSourceProvider),
  );
});
