import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

import '../../../../helpers/provider_test_helpers.dart';

void main() {
  group('itr2FormDataProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
      addTearDown(container.dispose);
    });

    test('starts with default Itr2FormData.empty()', () {
      final data = container.read(itr2FormDataProvider);

      expect(data, equals(Itr2FormData.empty()));
      expect(data.personalInfo, equals(PersonalInfo.empty()));
      expect(data.selectedRegime, equals(TaxRegime.newRegime));
    });

    test('updatePersonalInfo replaces personal info immutably', () {
      final updatedInfo = PersonalInfo.empty().copyWith(
        firstName: 'Rajesh',
        lastName: 'Kumar',
        pan: 'ABCPK1234F',
      );

      container
          .read(itr2FormDataProvider.notifier)
          .updatePersonalInfo(updatedInfo);

      final data = container.read(itr2FormDataProvider);
      expect(data.personalInfo.firstName, equals('Rajesh'));
      expect(data.personalInfo.lastName, equals('Kumar'));
      expect(data.personalInfo.pan, equals('ABCPK1234F'));
    });

    test('updatePersonalInfo does not mutate other fields', () {
      final before = container.read(itr2FormDataProvider);

      container
          .read(itr2FormDataProvider.notifier)
          .updatePersonalInfo(PersonalInfo.empty().copyWith(firstName: 'Test'));

      final after = container.read(itr2FormDataProvider);
      expect(after.scheduleCg, equals(before.scheduleCg));
      expect(after.deductions, equals(before.deductions));
      expect(after.selectedRegime, equals(before.selectedRegime));
    });

    test('updateScheduleCg replaces schedule cg', () {
      const newCg = ScheduleCg(
        equityStcgEntries: [],
        equityLtcgEntries: [],
        debtStcgEntries: [],
        debtLtcgEntries: [],
        propertyLtcgEntries: [],
        otherStcgEntries: [],
        otherLtcgEntries: [],
        broughtForwardStcl: 5000,
        broughtForwardLtcl: 10000,
      );

      container.read(itr2FormDataProvider.notifier).updateScheduleCg(newCg);

      final data = container.read(itr2FormDataProvider);
      expect(data.scheduleCg.broughtForwardStcl, equals(5000.0));
      expect(data.scheduleCg.broughtForwardLtcl, equals(10000.0));
    });

    test('updateDeductions replaces deductions', () {
      final newDeductions = ChapterViaDeductions.empty().copyWith(
        section80C: 150000,
      );

      container
          .read(itr2FormDataProvider.notifier)
          .updateDeductions(newDeductions);

      final data = container.read(itr2FormDataProvider);
      expect(data.deductions.section80C, equals(150000.0));
    });

    test('updateRegime switches tax regime', () {
      container
          .read(itr2FormDataProvider.notifier)
          .updateRegime(TaxRegime.oldRegime);

      final data = container.read(itr2FormDataProvider);
      expect(data.selectedRegime, equals(TaxRegime.oldRegime));
    });

    test('reset returns to empty state', () {
      container
          .read(itr2FormDataProvider.notifier)
          .updatePersonalInfo(
            PersonalInfo.empty().copyWith(firstName: 'Changed'),
          );
      container.read(itr2FormDataProvider.notifier).reset();

      final data = container.read(itr2FormDataProvider);
      expect(data, equals(Itr2FormData.empty()));
    });

    test('state is a new object after each update (immutable)', () {
      final before = container.read(itr2FormDataProvider);

      container
          .read(itr2FormDataProvider.notifier)
          .updatePersonalInfo(
            PersonalInfo.empty().copyWith(firstName: 'Changed'),
          );

      final after = container.read(itr2FormDataProvider);
      expect(identical(before, after), isFalse);
    });
  });

  group('itr2WizardStepProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
      addTearDown(container.dispose);
    });

    test('starts at step 0', () {
      final step = container.read(itr2WizardStepProvider);
      expect(step, equals(0));
    });

    test('goTo advances to the given step', () {
      container.read(itr2WizardStepProvider.notifier).goTo(3);
      expect(container.read(itr2WizardStepProvider), equals(3));
    });

    test('goTo(step + 1) increments step', () {
      container.read(itr2WizardStepProvider.notifier).goTo(1);
      container.read(itr2WizardStepProvider.notifier).goTo(2);
      expect(container.read(itr2WizardStepProvider), equals(2));
    });

    test('goTo(step - 1) decrements step', () {
      container.read(itr2WizardStepProvider.notifier).goTo(4);
      container.read(itr2WizardStepProvider.notifier).goTo(3);
      expect(container.read(itr2WizardStepProvider), equals(3));
    });

    test('step does not go below 0 when reset is called', () {
      container.read(itr2WizardStepProvider.notifier).goTo(3);
      container.read(itr2WizardStepProvider.notifier).reset();
      expect(container.read(itr2WizardStepProvider), equals(0));
    });

    test('goTo(0) when already at 0 stays at 0 (no negative step)', () {
      container.read(itr2WizardStepProvider.notifier).goTo(0);
      expect(container.read(itr2WizardStepProvider), equals(0));
    });

    test('goTo advances to last step (9)', () {
      container.read(itr2WizardStepProvider.notifier).goTo(9);
      expect(container.read(itr2WizardStepProvider), equals(9));
    });
  });
}
