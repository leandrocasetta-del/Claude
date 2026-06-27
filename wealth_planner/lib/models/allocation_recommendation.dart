import 'investor_profile.dart';

class AllocationRecommendation {
  final RiskProfile riskProfile;
  final Map<String, double> recommendedAllocations;
  final double offshorePercentage;
  final String rationale;
  final DateTime generatedAt;

  const AllocationRecommendation({
    required this.riskProfile,
    required this.recommendedAllocations,
    required this.offshorePercentage,
    required this.rationale,
    required this.generatedAt,
  });

  static AllocationRecommendation generateFor(InvestorProfile profile) {
    final Map<String, double> allocations;
    final double offshorePercentage;
    final String rationale;

    final bool isLongHorizon = profile.investmentHorizon >= 10;
    final bool hasForeignAssets = profile.hasForeignAssets;
    final bool hasSuccessionObjective =
        profile.objectives.contains('Sucessão familiar');
    final bool hasCurrencyProtection =
        profile.objectives.contains('Proteção cambial');
    final bool hasGeoDiv =
        profile.objectives.contains('Diversificação geográfica');

    final double offshoreBonus =
        (hasCurrencyProtection || hasGeoDiv || hasForeignAssets) ? 0.05 : 0;

    switch (profile.riskProfile) {
      case RiskProfile.conservative:
        allocations = {
          'Renda Fixa': 0.50,
          'Ações BR': 0.10,
          'FIIs': 0.10,
          'Ações Internacionais': 0.15 + offshoreBonus,
          'Criptomoedas': 0.02,
          'Caixa': 0.08,
          'Imóveis': 0.05,
        };
        offshorePercentage = 0.15 + offshoreBonus;
        rationale = _buildRationale(profile, 'conservador',
            'Sua carteira prioriza preservação de capital com alta alocação em Renda Fixa. '
            'O portfólio foi estruturado para resistir a períodos de alta volatilidade, '
            'mantendo liquidez adequada e exposição controlada a ativos de maior risco. '
            '${isLongHorizon ? "Com seu horizonte de ${profile.investmentHorizon} anos, há espaço para crescimento gradual da parcela de risco." : "Com horizonte de curto prazo, a segurança do capital é prioritária."}');
        break;

      case RiskProfile.moderate:
        allocations = {
          'Renda Fixa': 0.35,
          'Ações BR': 0.20,
          'FIIs': 0.10,
          'Ações Internacionais': 0.20 + offshoreBonus,
          'Criptomoedas': 0.05,
          'Caixa': 0.05,
          'Imóveis': 0.05,
        };
        offshorePercentage = 0.20 + offshoreBonus;
        rationale = _buildRationale(profile, 'moderado',
            'Sua carteira equilibra crescimento e segurança. A alocação em Renda Fixa garante '
            'estabilidade, enquanto ações e ativos internacionais impulsionam o crescimento. '
            '${isLongHorizon ? "Com ${profile.investmentHorizon} anos de horizonte, a exposição a risco pode gerar retornos superiores." : "O prazo de ${profile.investmentHorizon} anos permite adequada diversificação."}');
        break;

      case RiskProfile.aggressive:
        allocations = {
          'Renda Fixa': 0.15,
          'Ações BR': 0.30,
          'FIIs': 0.08,
          'Ações Internacionais': 0.27 + offshoreBonus,
          'Criptomoedas': 0.10,
          'Caixa': 0.03,
          'Imóveis': 0.07,
        };
        offshorePercentage = 0.27 + offshoreBonus;
        rationale = _buildRationale(profile, 'arrojado',
            'Sua carteira está orientada para crescimento máximo. Alta concentração em ações '
            'e ativos de risco visam retornos expressivos no longo prazo. '
            '${hasSuccessionObjective ? "Para seus objetivos de sucessão, considere estruturas offshore que otimizem a transmissão patrimonial. " : ""}'
            'A volatilidade será alta, mas o horizonte de ${profile.investmentHorizon} anos permite recuperação em ciclos adversos.');
        break;
    }

    // Normalize to ensure sum = 1.0
    final total = allocations.values.fold(0.0, (a, b) => a + b);
    if (total > 0 && (total - 1.0).abs() > 0.001) {
      final normalized = allocations.map(
        (k, v) => MapEntry(k, v / total),
      );
      return AllocationRecommendation(
        riskProfile: profile.riskProfile,
        recommendedAllocations: normalized,
        offshorePercentage: offshorePercentage,
        rationale: rationale,
        generatedAt: DateTime.now(),
      );
    }

    return AllocationRecommendation(
      riskProfile: profile.riskProfile,
      recommendedAllocations: allocations,
      offshorePercentage: offshorePercentage,
      rationale: rationale,
      generatedAt: DateTime.now(),
    );
  }

  static String _buildRationale(
      InvestorProfile profile, String profileName, String baseText) {
    final sb = StringBuffer(baseText);

    if (profile.objectives.isNotEmpty) {
      sb.write('\n\nSeus objetivos principais (');
      sb.write(profile.objectives.take(3).join(', '));
      sb.write(') foram considerados na estruturação.');
    }

    if (profile.dependents > 0) {
      sb.write(
          '\n\nCom ${profile.dependents} dependente(s), recomendamos manter reserva de emergência de pelo menos ${profile.dependents * 6} meses de despesas.');
    }

    return sb.toString();
  }

  List<String> getRebalancingSuggestions(Map<String, double> currentAllocations) {
    final suggestions = <String>[];
    for (final entry in recommendedAllocations.entries) {
      final current = currentAllocations[entry.key] ?? 0.0;
      final target = entry.value;
      final gap = target - current;
      if (gap.abs() > 0.05) {
        if (gap > 0) {
          suggestions.add('Aumentar ${entry.key}: +${(gap * 100).toStringAsFixed(1)}%');
        } else {
          suggestions.add('Reduzir ${entry.key}: ${(gap * 100).toStringAsFixed(1)}%');
        }
      }
    }
    return suggestions;
  }
}
