import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/firm_operations/data/datasources/firm_operations_local_source.dart';
import 'package:ca_app/features/firm_operations/data/datasources/firm_operations_remote_source.dart';
import 'package:ca_app/features/firm_operations/data/repositories/firm_operations_repository_impl.dart';
import 'package:ca_app/features/firm_operations/data/repositories/mock_firm_operations_repository.dart';
import 'package:ca_app/features/firm_operations/domain/repositories/firm_operations_repository.dart';

final firmOperationsRemoteSourceProvider =
    Provider<FirmOperationsRemoteSource>((ref) {
      return FirmOperationsRemoteSource(Supabase.instance.client);
    });

final firmOperationsLocalSourceProvider =
    Provider<FirmOperationsLocalSource>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return FirmOperationsLocalSource(db);
    });

final firmOperationsRepositoryProvider =
    Provider<FirmOperationsRepository>((ref) {
      final flags = ref.watch(featureFlagProvider);
      final useReal =
          flags.asData?.value.isEnabled('firm_operations_real_repo') ?? false;

      if (!useReal) {
        return MockFirmOperationsRepository();
      }

      final firmId = ref.watch(currentFirmIdProvider);
      return FirmOperationsRepositoryImpl(
        remote: ref.watch(firmOperationsRemoteSourceProvider),
        local: ref.watch(firmOperationsLocalSourceProvider),
        firmId: firmId,
      );
    });
