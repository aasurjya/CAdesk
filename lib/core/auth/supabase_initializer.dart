import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  assert(
    url.isNotEmpty,
    'SUPABASE_URL must be set via --dart-define=SUPABASE_URL=<value>',
  );
  assert(
    anonKey.isNotEmpty,
    'SUPABASE_ANON_KEY must be set via --dart-define=SUPABASE_ANON_KEY=<value>',
  );

  await Supabase.initialize(url: url, anonKey: anonKey);
}
