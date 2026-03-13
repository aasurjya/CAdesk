import 'package:ca_app/features/practice/domain/models/workflow.dart';

abstract class PracticeRepository {
  Future<String> insertWorkflow(Workflow workflow);
  Future<List<Workflow>> getAllWorkflows();
  Future<List<Workflow>> getByCategory(WorkflowCategory category);
  Future<Workflow?> getWorkflowById(String id);
  Future<bool> updateWorkflow(Workflow workflow);
  Future<bool> deleteWorkflow(String id);
  Future<List<Workflow>> getActiveWorkflows();
}
