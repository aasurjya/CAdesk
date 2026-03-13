import 'dart:async';

import 'package:ca_app/features/gst/domain/models/gst_client.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_client_repository.dart';

class MockGstClientRepository implements GstClientRepository {
  static final List<GstClient> _seedClients = [
    const GstClient(
      id: 'gst-client-1',
      businessName: 'ABC Infra Pvt Ltd',
      tradeName: 'ABC Infra',
      gstin: '27AABCA1234C1Z5',
      pan: 'AABCA1234C',
      registrationType: GstRegistrationType.regular,
      state: 'Maharashtra',
      stateCode: '27',
      returnsPending: ['GSTR-1', 'GSTR-3B'],
      complianceScore: 78,
    ),
    GstClient(
      id: 'gst-client-2',
      businessName: 'Mehta Sweet House',
      tradeName: 'Mehta Sweets',
      gstin: '24AAPFM5678D1Z8',
      pan: 'AAPFM5678D',
      registrationType: GstRegistrationType.composition,
      state: 'Gujarat',
      stateCode: '24',
      returnsPending: const ['GSTR-4'],
      lastFiledDate: DateTime(2026, 2, 18),
      complianceScore: 92,
    ),
    GstClient(
      id: 'gst-client-3',
      businessName: 'TechVista Solutions LLP',
      gstin: '29AAFT1234F1Z2',
      pan: 'AAFT1234F',
      registrationType: GstRegistrationType.regular,
      state: 'Karnataka',
      stateCode: '29',
      returnsPending: const [],
      lastFiledDate: DateTime(2026, 3, 10),
      complianceScore: 100,
    ),
  ];

  final List<GstClient> _state = List.of(_seedClients);
  final StreamController<List<GstClient>> _controller =
      StreamController<List<GstClient>>.broadcast();

  @override
  Future<List<GstClient>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<GstClient?> getById(String id) async {
    try {
      return _state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<GstClient?> getByGstin(String gstin) async {
    try {
      return _state.firstWhere((c) => c.gstin == gstin);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<GstClient> create(GstClient client) async {
    final updated = List<GstClient>.of(_state)..add(client);
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return client;
  }

  @override
  Future<GstClient> update(GstClient client) async {
    final idx = _state.indexWhere((c) => c.id == client.id);
    if (idx == -1) throw StateError('GstClient not found: ${client.id}');
    final updated = List<GstClient>.of(_state)..[idx] = client;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return client;
  }

  @override
  Future<void> delete(String id) async {
    final updated = List<GstClient>.of(_state)..removeWhere((c) => c.id == id);
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<GstClient>> search(String query, {String? firmId}) async {
    final q = query.toLowerCase();
    return _state
        .where(
          (c) =>
              c.businessName.toLowerCase().contains(q) ||
              (c.tradeName?.toLowerCase().contains(q) ?? false) ||
              c.gstin.toLowerCase().contains(q) ||
              c.pan.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Stream<List<GstClient>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}
