import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';

void main() {
  late ConfirmationGate gate;

  setUp(() {
    gate = ConfirmationGate();
  });

  tearDown(() {
    gate.dispose();
  });

  group('ConfirmationGate', () {
    test('isPending is false initially', () {
      expect(gate.isPending, isFalse);
    });

    test('isPending is true after waitForConfirmation is called', () async {
      // Don't await — we want to check the pending state
      final future = gate.waitForConfirmation();
      expect(gate.isPending, isTrue);

      // Clean up so tearDown doesn't throw
      gate.confirm();
      await future;
    });

    test('waitForConfirmation resolves when confirm is called', () async {
      final future = gate.waitForConfirmation();
      expect(gate.isPending, isTrue);

      gate.confirm();

      // Should complete without throwing
      await expectLater(future, completes);
      expect(gate.isPending, isFalse);
    });

    test('waitForConfirmation throws when reject is called', () async {
      final future = gate.waitForConfirmation();
      expect(gate.isPending, isTrue);

      gate.reject();

      await expectLater(future, throwsA(isA<ConfirmationRejectedException>()));
    });

    test('throws StateError if called while already pending', () async {
      gate.waitForConfirmation(); // ignore: unawaited_futures

      await expectLater(gate.waitForConfirmation(), throwsA(isA<StateError>()));

      // Clean up
      gate.confirm();
    });

    test('confirm is no-op when not pending', () {
      // Should not throw
      gate.confirm();
      expect(gate.isPending, isFalse);
    });

    test('reject is no-op when not pending', () {
      // Should not throw
      gate.reject();
      expect(gate.isPending, isFalse);
    });

    test('dispose rejects pending gate', () async {
      final future = gate.waitForConfirmation();
      expect(gate.isPending, isTrue);

      gate.dispose();

      await expectLater(future, throwsA(isA<ConfirmationRejectedException>()));
    });

    test('can be reused after confirm', () async {
      // First use
      final future1 = gate.waitForConfirmation();
      gate.confirm();
      await future1;

      // Second use
      final future2 = gate.waitForConfirmation();
      expect(gate.isPending, isTrue);
      gate.confirm();
      await expectLater(future2, completes);
    });
  });

  group('ConfirmationRejectedException', () {
    test('toString includes descriptive message', () {
      const e = ConfirmationRejectedException();
      expect(e.toString(), contains('cancelled'));
    });
  });
}
