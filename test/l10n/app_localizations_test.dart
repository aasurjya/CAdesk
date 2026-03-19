import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ca_app/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    group('supported locales', () {
      test('includes English', () {
        expect(
          AppLocalizations.supportedLocales.any((l) => l.languageCode == 'en'),
          isTrue,
        );
      });

      test('includes Hindi', () {
        expect(
          AppLocalizations.supportedLocales.any((l) => l.languageCode == 'hi'),
          isTrue,
        );
      });

      test('includes Gujarati', () {
        expect(
          AppLocalizations.supportedLocales.any((l) => l.languageCode == 'gu'),
          isTrue,
        );
      });

      test('includes Marathi', () {
        expect(
          AppLocalizations.supportedLocales.any((l) => l.languageCode == 'mr'),
          isTrue,
        );
      });
    });

    group('English strings', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('en'));
      });

      test('appTitle is CADesk', () {
        expect(l10n.appTitle, 'CADesk');
      });

      test('tabFiling is Filing', () {
        expect(l10n.tabFiling, 'Filing');
      });

      test('tabClients is Clients', () {
        expect(l10n.tabClients, 'Clients');
      });

      test('addClient is Add Client', () {
        expect(l10n.addClient, 'Add Client');
      });

      test('clientCount singular', () {
        expect(l10n.clientCount(1), '1 client');
      });

      test('clientCount plural', () {
        expect(l10n.clientCount(5), '5 clients');
      });

      test('statusAll is All', () {
        expect(l10n.statusAll, 'All');
      });

      test('statusActive is Active', () {
        expect(l10n.statusActive, 'Active');
      });

      test('next is Next', () {
        expect(l10n.next, 'Next');
      });

      test('back is Back', () {
        expect(l10n.back, 'Back');
      });

      test('save is Save', () {
        expect(l10n.save, 'Save');
      });

      test('deadlineDaysLeft zero days', () {
        expect(l10n.deadlineDaysLeft(0), 'Due today');
      });

      test('deadlineDaysLeft one day', () {
        expect(l10n.deadlineDaysLeft(1), '1 day left');
      });

      test('deadlineDaysLeft multiple days', () {
        expect(l10n.deadlineDaysLeft(5), '5 days left');
      });

      test('penaltyWarning includes amount', () {
        expect(l10n.penaltyWarning('5,000'), 'Penalty: ₹5,000');
      });

      test('exportFailed includes reason', () {
        expect(
          l10n.exportFailed('network error'),
          'Export failed: network error',
        );
      });

      test('confirmDeleteTitle includes name', () {
        expect(l10n.confirmDeleteTitle('Client ABC'), 'Delete Client ABC?');
      });

      test('filingYear formats year', () {
        expect(l10n.filingYear('2024-25'), 'FY 2024-25');
      });

      test('assessmentYear formats year', () {
        expect(l10n.assessmentYear('2025-26'), 'AY 2025-26');
      });
    });

    group('Hindi strings', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('hi'));
      });

      test('appTitle is CADesk', () {
        expect(l10n.appTitle, 'CADesk');
      });

      test('tabFiling is Hindi text', () {
        expect(l10n.tabFiling, 'फाइलिंग');
      });

      test('tabClients is Hindi text', () {
        expect(l10n.tabClients, 'क्लाइंट');
      });

      test('addClient is Hindi text', () {
        expect(l10n.addClient, 'क्लाइंट जोड़ें');
      });

      test('next is Hindi text', () {
        expect(l10n.next, 'अगला');
      });

      test('save is Hindi text', () {
        expect(l10n.save, 'सहेजें');
      });

      test('deadlineDaysLeft zero days', () {
        expect(l10n.deadlineDaysLeft(0), 'आज देय');
      });

      test('riskHigh is Hindi text', () {
        expect(l10n.riskHigh, 'उच्च जोखिम');
      });
    });

    group('Gujarati strings', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('gu'));
      });

      test('appTitle is CADesk', () {
        expect(l10n.appTitle, 'CADesk');
      });

      test('tabFiling is Gujarati text', () {
        expect(l10n.tabFiling, 'ફાઇલિંગ');
      });

      test('next is Gujarati text', () {
        expect(l10n.next, 'આગળ');
      });

      test('save is Gujarati text', () {
        expect(l10n.save, 'સાચવો');
      });
    });

    group('Marathi strings', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('mr'));
      });

      test('appTitle is CADesk', () {
        expect(l10n.appTitle, 'CADesk');
      });

      test('tabFiling is Marathi text', () {
        expect(l10n.tabFiling, 'फाइलिंग');
      });

      test('next is Marathi text', () {
        expect(l10n.next, 'पुढे');
      });

      test('save is Marathi text', () {
        expect(l10n.save, 'जतन करा');
      });
    });

    group('Widget integration', () {
      testWidgets('MaterialApp with localizations does not throw', (
        tester,
      ) async {
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

      testWidgets('Hindi locale resolves correctly', (tester) async {
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
    });
  });
}
