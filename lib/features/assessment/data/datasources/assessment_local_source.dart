import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/assessment/data/mappers/assessment_case_mapper.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';

class AssessmentLocalSource {
  const AssessmentLocalSource(this._db);

  final AppDatabase _db;

  Future<String> insertCase(AssessmentCase assessmentCase) => _db.assessmentDao
      .insertCase(AssessmentCaseMapper.toCompanion(assessmentCase));

  Future<List<AssessmentCase>> getByClient(String clientId) async {
    final rows = await _db.assessmentDao.getByClient(clientId);
    return rows.map(AssessmentCaseMapper.fromRow).toList();
  }

  Future<List<AssessmentCase>> getByYear(String assessmentYear) async {
    final rows = await _db.assessmentDao.getByYear(assessmentYear);
    return rows.map(AssessmentCaseMapper.fromRow).toList();
  }

  Future<List<AssessmentCase>> getByType(AssessmentType caseType) async {
    final rows = await _db.assessmentDao.getByType(caseType.name);
    return rows.map(AssessmentCaseMapper.fromRow).toList();
  }

  Future<List<AssessmentCase>> getByStatus(AssessmentCaseStatus status) async {
    final rows = await _db.assessmentDao.getByStatus(status.name);
    return rows.map(AssessmentCaseMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, AssessmentCaseStatus status) =>
      _db.assessmentDao.updateStatus(id, status.name);

  Future<List<AssessmentCase>> getOverdueDemands() async {
    final rows = await _db.assessmentDao.getOverdueDemands(DateTime.now());
    return rows.map(AssessmentCaseMapper.fromRow).toList();
  }
}
