import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/faceless_assessment/data/repositories/faceless_assessment_repository_impl.dart';
import 'package:ca_app/features/faceless_assessment/data/repositories/mock_faceless_assessment_repository.dart';
import 'package:ca_app/features/faceless_assessment/domain/repositories/faceless_assessment_repository.dart';

/// Provides the active [FacelessAssessmentRepository].
///
/// Returns [MockFacelessAssessmentRepository] unless the
/// `faceless_assessment_real_repo` feature flag is enabled, in which case
/// [FacelessAssessmentRepositoryImpl] (Supabase) is used.
final facelessAssessmentRepositoryProvider =
    Provider<FacelessAssessmentRepository>((ref) {
      final flags = ref.watch(featureFlagProvider);
      final useReal =
          flags.asData?.value.isEnabled('faceless_assessment_real_repo') ??
          false;

      if (!useReal) {
        return MockFacelessAssessmentRepository();
      }

      return FacelessAssessmentRepositoryImpl(Supabase.instance.client);
    });
