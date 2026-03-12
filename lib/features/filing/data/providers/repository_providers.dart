import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/data/repositories/in_memory_filing_job_repository.dart';
import 'package:ca_app/features/filing/data/repositories/in_memory_itr_form_data_repository.dart';
import 'package:ca_app/features/filing/domain/repositories/filing_job_repository.dart';
import 'package:ca_app/features/filing/domain/repositories/itr_form_data_repository.dart';

/// Filing job repository — swap implementation for production.
final filingJobRepositoryProvider = Provider<FilingJobRepository>((ref) {
  return InMemoryFilingJobRepository();
});

/// ITR form data repository — swap implementation for production.
final itrFormDataRepositoryProvider = Provider<ItrFormDataRepository>((ref) {
  return InMemoryItrFormDataRepository();
});
