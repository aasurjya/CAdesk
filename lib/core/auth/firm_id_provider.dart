import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/auth/auth_state.dart';
import 'package:ca_app/core/auth/supabase_auth_provider.dart';

/// Returns the current user's firmId, or empty string if not authenticated.
final currentFirmIdProvider = Provider<String>((ref) {
  final authAsync = ref.watch(authProvider);
  final auth = authAsync.asData?.value;
  if (auth is AuthAuthenticated) return auth.firmId ?? '';
  return '';
});
