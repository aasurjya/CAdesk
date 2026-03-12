import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';

/// Abstract repository for ITR form data persistence.
///
/// Each filing job can have at most one form data object per ITR type.
/// Concrete implementations handle serialization and storage.
abstract class ItrFormDataRepository {
  /// Retrieve ITR-1 form data for a filing job. Returns `null` if not saved.
  Future<Itr1FormData?> getItr1Data(String jobId);

  /// Persist ITR-1 form data for a filing job.
  Future<void> saveItr1Data(String jobId, Itr1FormData data);

  /// Delete form data for a filing job.
  Future<void> deleteFormData(String jobId);
}
