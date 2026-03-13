import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/app.dart';
import 'package:ca_app/core/auth/supabase_initializer.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await initializeSupabase();
      } catch (e, st) {
        // Log and continue — app will handle Supabase unavailability gracefully
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
      }
      runApp(const ProviderScope(child: CAApp()));
    },
    (error, stack) {
      // Global error handler — log unhandled errors
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    },
  );
}
