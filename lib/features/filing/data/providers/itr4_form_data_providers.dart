import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/services/itr4_tax_computation_engine.dart';

// ---------------------------------------------------------------------------
// ITR-4 form data notifier
// ---------------------------------------------------------------------------

class Itr4FormDataNotifier extends Notifier<Itr4FormData> {
  @override
  Itr4FormData build() => Itr4FormData.empty();

  void reset() => state = Itr4FormData.empty();

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
  }

  void updateBusinessIncome(BusinessIncome44AD income) {
    state = state.copyWith(businessIncome44AD: income);
  }

  void updateProfessionIncome(ProfessionIncome44ADA income) {
    state = state.copyWith(professionIncome44ADA: income);
  }

  void updateGoodsCarriageIncome(GoodsCarriageIncome44AE income) {
    state = state.copyWith(goodsCarriageIncome44AE: income);
  }

  void updateOtherSources(OtherSourceIncome os) {
    state = state.copyWith(otherSourceIncome: os);
  }

  void updateDeductions(ChapterViaDeductions d) {
    state = state.copyWith(deductions: d);
  }

  void updateRegime(TaxRegime regime) {
    state = state.copyWith(selectedRegime: regime);
  }
}

final itr4FormDataProvider =
    NotifierProvider<Itr4FormDataNotifier, Itr4FormData>(
      Itr4FormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived: live tax computation for ITR-4
// ---------------------------------------------------------------------------

final liveItr4TaxComputationProvider = Provider<TaxRegimeResult>((ref) {
  final formData = ref.watch(itr4FormDataProvider);
  return Itr4TaxComputationEngine.compare(formData);
});

// ---------------------------------------------------------------------------
// ITR-4 wizard step tracking
// ---------------------------------------------------------------------------

class _Itr4WizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;
  void goTo(int step) => state = step;
}

final itr4WizardStepProvider = NotifierProvider<_Itr4WizardStepNotifier, int>(
  _Itr4WizardStepNotifier.new,
);
