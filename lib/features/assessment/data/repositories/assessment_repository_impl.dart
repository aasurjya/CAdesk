import 'package:ca_app/features/assessment/data/datasources/assessment_local_source.dart';
import 'package:ca_app/features/assessment/data/datasources/assessment_remote_source.dart';
import 'package:ca_app/features/assessment/data/mappers/assessment_case_mapper.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';
import 'package:ca_app/features/assessment/domain/repositories/assessment_repository.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  const AssessmentRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final AssessmentRemoteSource remote;
  final AssessmentLocalSource local;

  @override
  Future<String> insertCase(AssessmentCase assessmentCase) async {
    try {
      final json = await remote.insert(
        AssessmentCaseMapper.toJson(assessmentCase),
      );
      final created = AssessmentCaseMapper.fromJson(json);
      await local.insertCase(created);
      return created.id;
    } catch (_) {
      return local.insertCase(assessmentCase);
    }
  }

  @override
  Future<List<AssessmentCase>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final cases = jsonList.map(AssessmentCaseMapper.fromJson).toList();
      for (final c in cases) {
        await local.updateStatus(c.id, c.status);
      }
      return List.unmodifiable(cases);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<AssessmentCase>> getByYear(String assessmentYear) async {
    try {
      final jsonList = await remote.fetchByYear(assessmentYear);
      return List.unmodifiable(
        jsonList.map(AssessmentCaseMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByYear(assessmentYear);
    }
  }

  @override
  Future<List<AssessmentCase>> getByType(AssessmentType caseType) async {
    try {
      final jsonList = await remote.fetchByType(caseType.name);
      return List.unmodifiable(
        jsonList.map(AssessmentCaseMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByType(caseType);
    }
  }

  @override
  Future<List<AssessmentCase>> getByStatus(
    AssessmentCaseStatus status,
  ) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      return List.unmodifiable(
        jsonList.map(AssessmentCaseMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<bool> updateStatus(String id, AssessmentCaseStatus status) async {
    try {
      await remote.update(id, {'status': status.name});
      return local.updateStatus(id, status);
    } catch (_) {
      return local.updateStatus(id, status);
    }
  }

  @override
  Future<List<AssessmentCase>> getOverdueDemands() async {
    // Aggregation of local data for overdue detection
    return local.getOverdueDemands();
  }
}
