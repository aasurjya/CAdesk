/// Hand-built mock for Supabase interactions in tests.
///
/// The real app accesses Supabase via `Supabase.instance.client` which returns
/// a [SupabaseClient]. Remote data sources accept the client directly (e.g.
/// `ClientsRemoteSource(SupabaseClient)`). This file provides lightweight
/// stand-ins that record calls and return canned data so tests never hit the
/// network.
///
/// Because [SupabaseClient] is a concrete class with platform bindings that
/// cannot be instantiated in unit tests, the recommended approach is to
/// override providers at the *data source* or *repository* level rather than
/// injecting a mock SupabaseClient directly.
///
/// Usage -- override a remote source provider:
/// ```dart
/// final mockRemote = MockSupabaseRemoteSource();
/// mockRemote.setResponse('clients', [{'id': '1', 'name': 'Test'}]);
/// ```
library;

/// A canned table query result used by [MockSupabaseRemoteSource].
class MockTableData {
  const MockTableData({this.rows = const [], this.error});

  /// The rows that queries on this table will return.
  final List<Map<String, dynamic>> rows;

  /// If non-null, operations on this table will throw this error message.
  final String? error;
}

/// Lightweight substitute for Supabase remote data source interactions.
///
/// Instead of mocking [SupabaseClient] (which has deep platform dependencies),
/// this class provides a simple key-value store of table -> rows that test
/// code can populate. Test doubles for remote data sources can delegate to
/// this object.
class MockSupabaseRemoteSource {
  final Map<String, MockTableData> _tables = {};
  final List<RecordedCall> _calls = [];

  /// All calls recorded by this mock, in order.
  List<RecordedCall> get calls => List.unmodifiable(_calls);

  /// Sets the canned response for [tableName].
  void setResponse(String tableName, List<Map<String, dynamic>> rows) {
    _tables[tableName] = MockTableData(rows: rows);
  }

  /// Configures [tableName] to throw on access.
  void setError(String tableName, String errorMessage) {
    _tables[tableName] = MockTableData(error: errorMessage);
  }

  /// Clears all configured responses and recorded calls.
  void reset() {
    _tables.clear();
    _calls.clear();
  }

  /// Simulates `supabase.from(table).select()`.
  Future<List<Map<String, dynamic>>> fetchAll(String tableName) async {
    _calls.add(RecordedCall(table: tableName, operation: 'fetchAll'));
    return _resolveTable(tableName).rows;
  }

  /// Simulates `supabase.from(table).select().eq('id', id).maybeSingle()`.
  Future<Map<String, dynamic>?> fetchById(String tableName, String id) async {
    _calls.add(
      RecordedCall(table: tableName, operation: 'fetchById', args: {'id': id}),
    );
    final rows = _resolveTable(tableName).rows;
    try {
      return rows.firstWhere((row) => row['id'] == id);
    } on StateError {
      return null;
    }
  }

  /// Simulates `supabase.from(table).insert(data).select().single()`.
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    _calls.add(RecordedCall(table: tableName, operation: 'insert', args: data));
    _resolveTable(tableName); // may throw if error configured
    return data;
  }

  /// Simulates `supabase.from(table).update(data).eq('id', id)`.
  Future<Map<String, dynamic>> update(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    _calls.add(
      RecordedCall(
        table: tableName,
        operation: 'update',
        args: {'id': id, ...data},
      ),
    );
    _resolveTable(tableName);
    return {'id': id, ...data};
  }

  /// Simulates `supabase.from(table).delete().eq('id', id)`.
  Future<void> delete(String tableName, String id) async {
    _calls.add(
      RecordedCall(table: tableName, operation: 'delete', args: {'id': id}),
    );
    _resolveTable(tableName);
  }

  MockTableData _resolveTable(String tableName) {
    final data = _tables[tableName] ?? const MockTableData();
    if (data.error != null) {
      throw Exception(data.error);
    }
    return data;
  }
}

/// A single recorded call to [MockSupabaseRemoteSource].
class RecordedCall {
  const RecordedCall({
    required this.table,
    required this.operation,
    this.args = const {},
  });

  final String table;
  final String operation;
  final Map<String, dynamic> args;

  @override
  String toString() => 'RecordedCall($table.$operation, $args)';
}
