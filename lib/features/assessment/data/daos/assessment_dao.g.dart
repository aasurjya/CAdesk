// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_dao.dart';

// ignore_for_file: type=lint
mixin _$AssessmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $AssessmentCasesTableTable get assessmentCasesTable =>
      attachedDatabase.assessmentCasesTable;
  AssessmentDaoManager get managers => AssessmentDaoManager(this);
}

class AssessmentDaoManager {
  final _$AssessmentDaoMixin _db;
  AssessmentDaoManager(this._db);
  $$AssessmentCasesTableTableTableManager get assessmentCasesTable =>
      $$AssessmentCasesTableTableTableManager(
        _db.attachedDatabase,
        _db.assessmentCasesTable,
      );
}
