import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/succession_plan.dart';
import '../core/constants.dart';

class SuccessionNotifier extends StateNotifier<AsyncValue<SuccessionPlan>> {
  SuccessionNotifier() : super(const AsyncValue.loading()) {
    loadPlan();
  }

  Future<void> loadPlan() async {
    try {
      state = const AsyncValue.loading();
      final box = Hive.box(AppConstants.successionBox);
      final data = box.get('current');
      if (data != null) {
        final plan = SuccessionPlan.fromMap(data as Map);
        state = AsyncValue.data(plan);
      } else {
        state = AsyncValue.data(SuccessionPlan.empty());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePlan(SuccessionPlan plan) async {
    try {
      final box = Hive.box(AppConstants.successionBox);
      await box.put('current', plan.toMap());
      state = AsyncValue.data(plan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateField({
    bool? hasWill,
    String? willJurisdiction,
    bool? holdingCompany,
    String? holdingCompanyName,
    bool? donationInLife,
    double? donationAmount,
    double? itcmdEstimate,
    bool? trustStructure,
    bool? lifeInsurance,
    double? lifeInsuranceValue,
    List<String>? beneficiaries,
    String? notes,
  }) async {
    final current = state.valueOrNull ?? SuccessionPlan.empty();
    final updated = current.copyWith(
      hasWill: hasWill,
      willJurisdiction: willJurisdiction,
      holdingCompany: holdingCompany,
      holdingCompanyName: holdingCompanyName,
      donationInLife: donationInLife,
      donationAmount: donationAmount,
      itcmdEstimate: itcmdEstimate,
      trustStructure: trustStructure,
      lifeInsurance: lifeInsurance,
      lifeInsuranceValue: lifeInsuranceValue,
      beneficiaries: beneficiaries,
      notes: notes,
    );
    await savePlan(updated);
  }
}

final successionProvider =
    StateNotifierProvider<SuccessionNotifier, AsyncValue<SuccessionPlan>>(
  (ref) => SuccessionNotifier(),
);
