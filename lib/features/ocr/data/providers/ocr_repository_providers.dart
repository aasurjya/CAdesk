import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/ocr/data/datasources/ocr_local_source.dart';
import 'package:ca_app/features/ocr/data/datasources/ocr_remote_source.dart';
import 'package:ca_app/features/ocr/data/repositories/mock_ocr_repository.dart';
import 'package:ca_app/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:ca_app/features/ocr/domain/repositories/ocr_repository.dart';

final ocrRemoteSourceProvider = Provider<OcrRemoteSource>((ref) {
  return OcrRemoteSource(Supabase.instance.client);
});

final ocrLocalSourceProvider = Provider<OcrLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return OcrLocalSource(db);
});

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('ocr_real_repo') ?? false;

  if (!useReal) {
    return MockOcrRepository();
  }

  return OcrRepositoryImpl(
    remote: ref.watch(ocrRemoteSourceProvider),
    local: ref.watch(ocrLocalSourceProvider),
  );
});
