import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr2/foreign_asset_schedule.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

// ---------------------------------------------------------------------------
// ITR-2 form data notifier
// ---------------------------------------------------------------------------

class Itr2FormDataNotifier extends Notifier<Itr2FormData> {
  @override
  Itr2FormData build() => Itr2FormData.empty();

  void reset() {
    state = Itr2FormData.empty();
  }

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
  }

  void updateSalaryIncome(SalaryIncome income) {
    state = state.copyWith(salaryIncome: income);
  }

  void updateHouseProperty(HousePropertyIncome hp) {
    state = state.copyWith(housePropertyIncome: hp);
  }

  void updateOtherSources(OtherSourceIncome os) {
    state = state.copyWith(otherSourceIncome: os);
  }

  void updateScheduleCg(ScheduleCg cg) {
    state = state.copyWith(scheduleCg: cg);
  }

  void updateForeignAssets(ForeignAssetSchedule fa) {
    state = state.copyWith(foreignAssetSchedule: fa);
  }

  void updateScheduleAl(ScheduleAl? al) {
    state = state.copyWith(scheduleAl: al);
  }

  void updateDeductions(ChapterViaDeductions d) {
    state = state.copyWith(deductions: d);
  }

  void updateRegime(TaxRegime regime) {
    state = state.copyWith(selectedRegime: regime);
  }
}

final itr2FormDataProvider =
    NotifierProvider<Itr2FormDataNotifier, Itr2FormData>(
      Itr2FormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// ITR-2 wizard step tracking (0..9)
// ---------------------------------------------------------------------------

class _Itr2WizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;

  void goTo(int step) => state = step;
}

/// Zero-based index of the currently visible ITR-2 wizard step (0..9).
final itr2WizardStepProvider = NotifierProvider<_Itr2WizardStepNotifier, int>(
  _Itr2WizardStepNotifier.new,
);
