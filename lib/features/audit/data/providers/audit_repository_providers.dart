import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/audit/data/datasources/audit_local_source.dart';
import 'package:ca_app/features/audit/data/datasources/audit_remote_source.dart';
import 'package:ca_app/features/audit/data/repositories/audit_repository_impl.dart';
import 'package:ca_app/features/audit/data/repositories/mock_audit_repository.dart';
import 'package:ca_app/features/audit/domain/repositories/audit_repository.dart';

final auditRemoteSourceProvider = Provider<AuditRemoteSource>((ref) {
  return AuditRemoteSource(Supabase.instance.client);
});

final auditLocalSourceProvider = Provider<AuditLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuditLocalSource(db);
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('audit_real_repo') ?? false;

  if (!useReal) {
    return MockAuditRepository();
  }

  return AuditRepositoryImpl(
    remote: ref.watch(auditRemoteSourceProvider),
    local: ref.watch(auditLocalSourceProvider),
  );
});
