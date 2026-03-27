import 'dart:async';

import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/repositories/client_repository.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/domain/repositories/invoice_repository.dart';

// ---------------------------------------------------------------------------
// Generic in-memory store
// ---------------------------------------------------------------------------

/// A generic in-memory data store that mock repositories can delegate to.
/// All operations return new lists (never expose internal state).
class InMemoryStore<T> {
  final List<T> _items = [];
  final StreamController<List<T>> _controller = StreamController.broadcast();

  /// Returns an unmodifiable snapshot of the current items.
  List<T> get items => List.unmodifiable(_items);

  /// Replaces all items and notifies watchers.
  void seed(List<T> items) {
    _items
      ..clear()
      ..addAll(items);
    _notify();
  }

  /// Adds an item and notifies watchers.
  void add(T item) {
    _items.add(item);
    _notify();
  }

  /// Replaces an item matching [predicate] and notifies watchers.
  /// If no match is found, adds the item.
  void upsert(T item, bool Function(T existing) predicate) {
    final index = _items.indexWhere(predicate);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
    _notify();
  }

  /// Removes items matching [predicate] and notifies watchers.
  void removeWhere(bool Function(T item) predicate) {
    _items.removeWhere(predicate);
    _notify();
  }

  /// Returns a broadcast stream of snapshots.
  Stream<List<T>> watch() => _controller.stream.map(List.unmodifiable);

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  /// Cleans up the stream controller. Call in tearDown.
  void dispose() {
    _controller.close();
  }
}

// ---------------------------------------------------------------------------
// Mock ClientRepository
// ---------------------------------------------------------------------------

/// Hand-built mock [ClientRepository] backed by an [InMemoryStore].
///
/// Usage:
/// ```dart
/// final mockRepo = MockClientRepositoryForTest();
/// mockRepo.store.seed([makeClient(), makeClient(name: 'Client 2')]);
/// ```
class MockClientRepositoryForTest implements ClientRepository {
  final InMemoryStore<Client> store = InMemoryStore<Client>();

  @override
  Future<List<Client>> getAll({String? firmId}) async => store.items;

  @override
  Future<Client?> getById(String id) async {
    try {
      return store.items.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Client> create(Client client) async {
    store.add(client);
    return client;
  }

  @override
  Future<Client> update(Client client) async {
    store.upsert(client, (existing) => existing.id == client.id);
    return client;
  }

  @override
  Future<void> delete(String id) async {
    store.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Client>> search(String query, {String? firmId}) async {
    final lower = query.toLowerCase();
    return store.items
        .where(
          (c) =>
              c.name.toLowerCase().contains(lower) ||
              c.pan.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Stream<List<Client>> watchAll({String? firmId}) => store.watch();
}

// ---------------------------------------------------------------------------
// Mock InvoiceRepository
// ---------------------------------------------------------------------------

/// Hand-built mock [InvoiceRepository] backed by an [InMemoryStore].
class MockInvoiceRepositoryForTest implements InvoiceRepository {
  final InMemoryStore<Invoice> store = InMemoryStore<Invoice>();

  @override
  Future<List<Invoice>> getAll({String? firmId}) async => store.items;

  @override
  Future<Invoice?> getById(String id) async {
    try {
      return store.items.firstWhere((inv) => inv.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Invoice> create(Invoice invoice) async {
    store.add(invoice);
    return invoice;
  }

  @override
  Future<Invoice> update(Invoice invoice) async {
    store.upsert(invoice, (existing) => existing.id == invoice.id);
    return invoice;
  }

  @override
  Future<void> delete(String id) async {
    store.removeWhere((inv) => inv.id == id);
  }

  @override
  Future<List<Invoice>> getByClientId(String clientId) async {
    return store.items.where((inv) => inv.clientId == clientId).toList();
  }

  @override
  Future<List<Invoice>> getByStatus(
    InvoiceStatus status, {
    String? firmId,
  }) async {
    return store.items.where((inv) => inv.status == status).toList();
  }

  @override
  Future<List<Invoice>> search(String query, {String? firmId}) async {
    final lower = query.toLowerCase();
    return store.items
        .where(
          (inv) =>
              inv.clientName.toLowerCase().contains(lower) ||
              inv.invoiceNumber.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Stream<List<Invoice>> watchAll({String? firmId}) => store.watch();
}

// ---------------------------------------------------------------------------
// Callable recorder for verifying interactions
// ---------------------------------------------------------------------------

/// Records method calls for assertion. Useful when a mock doesn't need
/// real behaviour but tests need to verify that a method was invoked.
///
/// ```dart
/// final recorder = CallRecorder();
/// // inside mock:  recorder.record('delete', {'id': id});
/// // in test:      expect(recorder.called('delete'), isTrue);
/// ```
class CallRecorder {
  final List<({String method, Map<String, dynamic> args})> _calls = [];

  /// Records a method invocation.
  void record(String method, [Map<String, dynamic> args = const {}]) {
    _calls.add((method: method, args: args));
  }

  /// Whether [method] was called at least once.
  bool called(String method) => _calls.any((c) => c.method == method);

  /// Number of times [method] was called.
  int callCount(String method) =>
      _calls.where((c) => c.method == method).length;

  /// Returns all recorded calls for [method].
  List<Map<String, dynamic>> argsFor(String method) =>
      _calls.where((c) => c.method == method).map((c) => c.args).toList();

  /// Clears all recorded calls.
  void reset() => _calls.clear();
}
