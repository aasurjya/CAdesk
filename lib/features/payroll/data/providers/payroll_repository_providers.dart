import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/payroll/data/datasources/payroll_local_source.dart';
import 'package:ca_app/features/payroll/data/datasources/payroll_remote_source.dart';
import 'package:ca_app/features/payroll/data/repositories/mock_payroll_repository.dart';
import 'package:ca_app/features/payroll/data/repositories/payroll_repository_impl.dart';
import 'package:ca_app/features/payroll/domain/repositories/payroll_repository.dart';

/// Provides the [PayrollRemoteSource] (Supabase client).
final payrollRemoteSourceProvider = Provider<PayrollRemoteSource>((ref) {
  return PayrollRemoteSource(Supabase.instance.client);
});

/// Provides the [PayrollLocalSource] (Drift/SQLite).
final payrollLocalSourceProvider = Provider<PayrollLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PayrollLocalSource(db);
});

/// Provides the active [PayrollRepository].
///
/// Returns [MockPayrollRepository] unless the `payroll_real_repo` feature
/// flag is enabled, in which case [PayrollRepositoryImpl] is used.
final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('payroll_real_repo') ?? false;

  if (!useReal) {
    return MockPayrollRepository();
  }

  return PayrollRepositoryImpl(
    remote: ref.watch(payrollRemoteSourceProvider),
    local: ref.watch(payrollLocalSourceProvider),
  );
});
