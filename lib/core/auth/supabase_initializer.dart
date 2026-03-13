import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'http://127.0.0.1:54321',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    ),
  );
}
