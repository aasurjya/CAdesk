import 'package:ca_app/features/practice/data/datasources/practice_local_source.dart';
import 'package:ca_app/features/practice/data/datasources/practice_remote_source.dart';
import 'package:ca_app/features/practice/data/mappers/practice_mapper.dart';
import 'package:ca_app/features/practice/domain/models/workflow.dart';
import 'package:ca_app/features/practice/domain/repositories/practice_repository.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  const PracticeRepositoryImpl({required this.remote, required this.local});

  final PracticeRemoteSource remote;
  final PracticeLocalSource local;

  @override
  Future<String> insertWorkflow(Workflow workflow) async {
    try {
      final json = await remote.insert(PracticeMapper.workflowToJson(workflow));
      final created = PracticeMapper.workflowFromJson(json);
      await local.insertWorkflow(created);
      return created.id;
    } catch (_) {
      return local.insertWorkflow(workflow);
    }
  }

  @override
  Future<List<Workflow>> getAllWorkflows() async {
    try {
      final jsonList = await remote.fetchAll();
      final workflows = jsonList.map(PracticeMapper.workflowFromJson).toList();
      for (final w in workflows) {
        await local.updateWorkflow(w);
      }
      return List.unmodifiable(workflows);
    } catch (_) {
      return local.getAllWorkflows();
    }
  }

  @override
  Future<List<Workflow>> getByCategory(WorkflowCategory category) async {
    try {
      final jsonList = await remote.fetchByCategory(category.name);
      return List.unmodifiable(
        jsonList.map(PracticeMapper.workflowFromJson).toList(),
      );
    } catch (_) {
      return local.getByCategory(category);
    }
  }

  @override
  Future<Workflow?> getWorkflowById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final workflow = PracticeMapper.workflowFromJson(json);
      await local.updateWorkflow(workflow);
      return workflow;
    } catch (_) {
      return local.getWorkflowById(id);
    }
  }

  @override
  Future<bool> updateWorkflow(Workflow workflow) async {
    try {
      await remote.update(workflow.id, PracticeMapper.workflowToJson(workflow));
      return local.updateWorkflow(workflow);
    } catch (_) {
      return local.updateWorkflow(workflow);
    }
  }

  @override
  Future<bool> deleteWorkflow(String id) async {
    await remote.delete(id);
    return local.deleteWorkflow(id);
  }

  @override
  Future<List<Workflow>> getActiveWorkflows() async {
    try {
      final jsonList = await remote.fetchAll();
      final all = jsonList.map(PracticeMapper.workflowFromJson).toList();
      return List.unmodifiable(all.where((w) => w.isActive).toList());
    } catch (_) {
      return local.getActiveWorkflows();
    }
  }
}
