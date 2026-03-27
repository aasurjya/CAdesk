import 'package:drift/native.dart';
import 'package:ca_app/core/database/app_database.dart';

/// Creates an in-memory [AppDatabase] for testing.
///
/// The database uses Drift's [NativeDatabase.memory] backend so no file I/O
/// occurs. Caller must call [AppDatabase.close] in tearDown to release
/// resources.
///
/// Example:
/// ```dart
/// late AppDatabase db;
/// setUp(() => db = createTestDatabase());
/// tearDown(() => db.close());
/// ```
AppDatabase createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}
