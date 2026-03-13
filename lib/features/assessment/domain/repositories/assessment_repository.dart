import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';

abstract class AssessmentRepository {
  Future<String> insertCase(AssessmentCase assessmentCase);
  Future<List<AssessmentCase>> getByClient(String clientId);
  Future<List<AssessmentCase>> getByYear(String assessmentYear);
  Future<List<AssessmentCase>> getByType(AssessmentType caseType);
  Future<List<AssessmentCase>> getByStatus(AssessmentCaseStatus status);
  Future<bool> updateStatus(String id, AssessmentCaseStatus status);

  /// Returns all open cases with a dueDate in the past (overdue demands).
  Future<List<AssessmentCase>> getOverdueDemands();
}
