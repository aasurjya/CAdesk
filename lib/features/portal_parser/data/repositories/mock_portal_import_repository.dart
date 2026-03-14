import 'dart:async';

import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';
import 'package:ca_app/features/portal_parser/domain/repositories/portal_import_repository.dart';

class MockPortalImportRepository implements PortalImportRepository {
  static final List<PortalImport> _seed = [
    PortalImport(
      id: 'pi-001',
      clientId: 'client-1',
      importType: ImportType.form26as,
      importDate: DateTime(2025, 7, 1),
      parsedRecords: 45,
      status: ImportStatus.completed,
      createdAt: DateTime(2025, 7, 1),
    ),
    PortalImport(
      id: 'pi-002',
      clientId: 'client-1',
      importType: ImportType.ais,
      importDate: DateTime(2025, 6, 15),
      parsedRecords: 12,
      status: ImportStatus.completed,
      createdAt: DateTime(2025, 6, 15),
    ),
    PortalImport(
      id: 'pi-003',
      clientId: 'client-2',
      importType: ImportType.tracesStatement,
      importDate: DateTime(2025, 5, 10),
      status: ImportStatus.failed,
      errorMessage: 'Invalid file format',
      createdAt: DateTime(2025, 5, 10),
    ),
  ];

  final List<PortalImport> _state = List.of(_seed);
  final StreamController<List<PortalImport>> _controller =
      StreamController<List<PortalImport>>.broadcast();

  @override
  Future<void> insert(PortalImport import) async {
    _state.add(import);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<PortalImport>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((i) => i.clientId == clientId).toList());

  @override
  Future<List<PortalImport>> getByType(ImportType type) async =>
      List.unmodifiable(_state.where((i) => i.importType == type).toList());

  @override
  Future<PortalImport?> getLatest(String clientId, ImportType type) async {
    final matches =
        _state
            .where((i) => i.clientId == clientId && i.importType == type)
            .toList()
          ..sort((a, b) => b.importDate.compareTo(a.importDate));
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<bool> updateStatus(
    String id,
    ImportStatus status, {
    int? parsedRecords,
    String? errorMessage,
  }) async {
    final idx = _state.indexWhere((i) => i.id == id);
    if (idx == -1) return false;
    final updated = List<PortalImport>.of(_state);
    updated[idx] = _state[idx].copyWith(
      status: status,
      parsedRecords: parsedRecords,
      errorMessage: errorMessage,
    );
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return true;
  }

  @override
  Future<PortalImport?> getById(String id) async {
    try {
      return _state.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<PortalImport>> watchByClient(String clientId) => _controller
      .stream
      .map((list) => list.where((i) => i.clientId == clientId).toList());

  void dispose() => _controller.close();
}
