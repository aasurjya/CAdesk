import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/l10n/app_localizations.dart';

void main() {
  group('CAApp l10n', () {
    test('supported locales includes all 4 languages', () {
      const locales = AppLocalizations.supportedLocales;
      final codes = locales.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(['en', 'hi', 'gu', 'mr']));
    });

    testWidgets('AppLocalizations delegate loads English', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('CADesk'), findsOneWidget);
    });

    testWidgets('Hindi locale resolves tabClients correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.tabClients);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('क्लाइंट'), findsOneWidget);
    });

    testWidgets('Gujarati locale resolves tabFiling correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('gu'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.tabFiling);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ફાઇલિંગ'), findsOneWidget);
    });

    testWidgets('Marathi locale resolves next correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('mr'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.next);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('पुढे'), findsOneWidget);
    });
  });
}
