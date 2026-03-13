import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/clients/data/datasources/clients_local_source.dart';
import 'package:ca_app/features/clients/data/datasources/clients_remote_source.dart';
import 'package:ca_app/features/clients/data/repositories/client_repository_impl.dart';
import 'package:ca_app/features/clients/data/repositories/mock_client_repository.dart';
import 'package:ca_app/features/clients/domain/repositories/client_repository.dart';

final clientsRemoteSourceProvider = Provider<ClientsRemoteSource>((ref) {
  return ClientsRemoteSource(Supabase.instance.client);
});

final clientsLocalSourceProvider = Provider<ClientsLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClientsLocalSource(db);
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('clients_real_repo') ?? false;

  if (!useReal) {
    return MockClientRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return ClientRepositoryImpl(
    remote: ref.watch(clientsRemoteSourceProvider),
    local: ref.watch(clientsLocalSourceProvider),
    firmId: firmId,
  );
});
