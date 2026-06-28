import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/allocation_recommendation.dart';
import '../models/investor_profile.dart';
import 'profile_provider.dart';

final allocationRecommendationProvider =
    Provider<AllocationRecommendation?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final profile = profileAsync.valueOrNull;
  if (profile == null) return null;
  return AllocationRecommendation.generateFor(profile);
});

final defaultRecommendationProvider =
    Provider<AllocationRecommendation>((ref) {
  final recommendation = ref.watch(allocationRecommendationProvider);
  if (recommendation != null) return recommendation;

  // Default moderate profile
  final defaultProfile = InvestorProfile(
    id: 'default',
    name: 'Investidor',
    cpf: '',
    birthDate: DateTime(1985),
    maritalStatus: 'Solteiro(a)',
    dependents: 0,
    monthlyIncome: 20000,
    totalPatrimony: 500000,
    riskProfile: RiskProfile.moderate,
    investmentHorizon: 10,
    objectives: [],
    hasMinors: false,
    hasForeignAssets: false,
    foreignAssetsValue: 0,
    residenceCountry: 'Brasil',
    taxResidency: 'Brasil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  return AllocationRecommendation.generateFor(defaultProfile);
});
