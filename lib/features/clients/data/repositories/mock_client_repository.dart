import 'dart:async';

import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/domain/repositories/client_repository.dart';

class MockClientRepository implements ClientRepository {
  // Mock data list — mirrors the existing mockClients in client_providers.dart
  // but scoped to this repository for test/offline use.
  static final List<Client> _seedClients = [
    Client(
      id: '1',
      name: 'Rajesh Kumar Sharma',
      pan: 'ABCPS1234A',
      email: 'rajesh.sharma@gmail.com',
      phone: '9876543210',
      clientType: ClientType.individual,
      dateOfBirth: DateTime(1975, 6, 15),
      address: '42, MG Road, Bandra West',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400050',
      servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
      status: ClientStatus.active,
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2026, 3, 1),
      notes: 'Senior manager at TCS. Files ITR-2 every year.',
    ),
    Client(
      id: '2',
      name: 'Priya Mehta',
      pan: 'BQKPM5678B',
      email: 'priya.mehta@outlook.com',
      phone: '9988776655',
      clientType: ClientType.individual,
      dateOfBirth: DateTime(1988, 11, 22),
      address: '15, Jubilee Hills',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500033',
      servicesAvailed: [ServiceType.itrFiling],
      status: ClientStatus.active,
      createdAt: DateTime(2024, 4, 5),
      updatedAt: DateTime(2026, 2, 20),
      notes: 'Freelance designer. Has capital gains from equity.',
    ),
    Client(
      id: '3',
      name: 'ABC Infra Pvt Ltd',
      pan: 'AABCA1234C',
      email: 'accounts@abcinfra.in',
      phone: '9111222333',
      clientType: ClientType.company,
      dateOfIncorporation: DateTime(2015, 3, 12),
      address: '201, Business Tower, Connaught Place',
      city: 'New Delhi',
      state: 'Delhi',
      pincode: '110001',
      gstin: '07AABCA1234C1Z5',
      tan: 'DELA12345B',
      servicesAvailed: [
        ServiceType.itrFiling,
        ServiceType.gstFiling,
        ServiceType.tds,
        ServiceType.audit,
      ],
      status: ClientStatus.active,
      createdAt: DateTime(2023, 7, 1),
      updatedAt: DateTime(2026, 3, 5),
      notes: 'Infrastructure company. Turnover above 10 Cr.',
    ),
    Client(
      id: '4',
      name: 'Mehta & Sons',
      pan: 'AAPFM5678D',
      email: 'mehtasons@yahoo.com',
      phone: '9444555666',
      clientType: ClientType.firm,
      address: '78, Ashram Road',
      city: 'Ahmedabad',
      state: 'Gujarat',
      pincode: '380009',
      gstin: '24AAPFM5678D1Z8',
      servicesAvailed: [
        ServiceType.itrFiling,
        ServiceType.gstFiling,
        ServiceType.bookkeeping,
      ],
      status: ClientStatus.active,
      createdAt: DateTime(2023, 11, 15),
      updatedAt: DateTime(2026, 2, 28),
    ),
    Client(
      id: '5',
      name: 'TechVista Solutions LLP',
      pan: 'AAFT1234F',
      email: 'finance@techvista.co.in',
      phone: '8055667788',
      clientType: ClientType.llp,
      dateOfIncorporation: DateTime(2019, 8, 1),
      address: '504, Whitefield Tech Park',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560066',
      gstin: '29AAFT1234F1Z2',
      tan: 'BLRT56789A',
      servicesAvailed: [
        ServiceType.itrFiling,
        ServiceType.gstFiling,
        ServiceType.tds,
        ServiceType.payroll,
      ],
      status: ClientStatus.active,
      createdAt: DateTime(2023, 9, 10),
      updatedAt: DateTime(2026, 3, 8),
    ),
  ];

  final List<Client> _state = List.of(_seedClients);
  final StreamController<List<Client>> _controller =
      StreamController<List<Client>>.broadcast();

  @override
  Future<List<Client>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<Client?> getById(String id) async {
    try {
      return _state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Client> create(Client client) async {
    _state.add(client);
    _controller.add(List.unmodifiable(_state));
    return client;
  }

  @override
  Future<Client> update(Client client) async {
    final idx = _state.indexWhere((c) => c.id == client.id);
    if (idx == -1) throw StateError('Client not found: ${client.id}');
    // Immutable replacement — do not mutate the list item in-place
    final updated = List<Client>.of(_state);
    updated[idx] = client;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return client;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((c) => c.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<Client>> search(String query, {String? firmId}) async {
    final q = query.toLowerCase();
    return _state
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.pan.toLowerCase().contains(q) ||
              (c.email?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Stream<List<Client>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}
