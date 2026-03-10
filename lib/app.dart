import 'package:flutter/material.dart';
import 'package:ca_app/core/theme/app_theme.dart';

class CAApp extends StatelessWidget {
  const CAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CA App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('CA App'),
        ),
      ),
    );
  }
}
