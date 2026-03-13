import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/documents/data/datasources/documents_local_source.dart';
import 'package:ca_app/features/documents/data/datasources/documents_remote_source.dart';
import 'package:ca_app/features/documents/data/repositories/document_repository_impl.dart';
import 'package:ca_app/features/documents/data/repositories/mock_document_repository.dart';
import 'package:ca_app/features/documents/domain/repositories/document_repository.dart';

final documentsRemoteSourceProvider = Provider<DocumentsRemoteSource>((ref) {
  return DocumentsRemoteSource(Supabase.instance.client);
});

final documentsLocalSourceProvider = Provider<DocumentsLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DocumentsLocalSource(db);
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('documents_real_repo') ?? false;

  if (!useReal) {
    return MockDocumentRepository();
  }

  return DocumentRepositoryImpl(
    remote: ref.watch(documentsRemoteSourceProvider),
    local: ref.watch(documentsLocalSourceProvider),
  );
});
