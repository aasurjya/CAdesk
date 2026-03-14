import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/post_filing/data/datasources/post_filing_record_local_source.dart';
import 'package:ca_app/features/post_filing/data/datasources/post_filing_record_remote_source.dart';
import 'package:ca_app/features/post_filing/data/repositories/post_filing_record_repository_impl.dart';
import 'package:ca_app/features/post_filing/data/repositories/mock_post_filing_record_repository.dart';
import 'package:ca_app/features/post_filing/domain/repositories/post_filing_record_repository.dart';

final postFilingRecordRemoteSourceProvider =
    Provider<PostFilingRecordRemoteSource>((ref) {
      return PostFilingRecordRemoteSource(Supabase.instance.client);
    });

final postFilingRecordLocalSourceProvider =
    Provider<PostFilingRecordLocalSource>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return PostFilingRecordLocalSource(db);
    });

final postFilingRecordRepositoryProvider = Provider<PostFilingRecordRepository>(
  (ref) {
    final flags = ref.watch(featureFlagProvider);
    final useReal =
        flags.asData?.value.isEnabled('post_filing_real_repo') ?? false;

    if (!useReal) {
      return MockPostFilingRecordRepository();
    }

    return PostFilingRecordRepositoryImpl(
      remote: ref.watch(postFilingRecordRemoteSourceProvider),
      local: ref.watch(postFilingRecordLocalSourceProvider),
    );
  },
);
