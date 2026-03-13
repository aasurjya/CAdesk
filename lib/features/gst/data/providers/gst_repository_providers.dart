import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/gst/data/datasources/gst_client_local_source.dart';
import 'package:ca_app/features/gst/data/datasources/gst_client_remote_source.dart';
import 'package:ca_app/features/gst/data/datasources/gst_return_local_source.dart';
import 'package:ca_app/features/gst/data/datasources/gst_return_remote_source.dart';
import 'package:ca_app/features/gst/data/repositories/gst_client_repository_impl.dart';
import 'package:ca_app/features/gst/data/repositories/gst_return_repository_impl.dart';
import 'package:ca_app/features/gst/data/repositories/mock_gst_client_repository.dart';
import 'package:ca_app/features/gst/data/repositories/mock_gst_return_repository.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_client_repository.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_return_repository.dart';

final gstClientRemoteSourceProvider = Provider<GstClientRemoteSource>((ref) {
  return GstClientRemoteSource(Supabase.instance.client);
});

final gstClientLocalSourceProvider = Provider<GstClientLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GstClientLocalSource(db);
});

final gstReturnRemoteSourceProvider = Provider<GstReturnRemoteSource>((ref) {
  return GstReturnRemoteSource(Supabase.instance.client);
});

final gstReturnLocalSourceProvider = Provider<GstReturnLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GstReturnLocalSource(db);
});

final gstClientRepositoryProvider = Provider<GstClientRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('gst_real_repo') ?? false;

  if (!useReal) {
    return MockGstClientRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return GstClientRepositoryImpl(
    remote: ref.watch(gstClientRemoteSourceProvider),
    local: ref.watch(gstClientLocalSourceProvider),
    firmId: firmId,
  );
});

final gstReturnRepositoryProvider = Provider<GstReturnRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('gst_real_repo') ?? false;

  if (!useReal) {
    return MockGstReturnRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return GstReturnRepositoryImpl(
    remote: ref.watch(gstReturnRemoteSourceProvider),
    local: ref.watch(gstReturnLocalSourceProvider),
    firmId: firmId,
  );
});
