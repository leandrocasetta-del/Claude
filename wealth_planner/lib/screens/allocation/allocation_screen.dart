import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/asset.dart';
import '../../providers/allocation_provider.dart';
import '../../providers/assets_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/section_header.dart';

class AllocationScreen extends ConsumerWidget {
  const AllocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final assetsAsync = ref.watch(assetsProvider);
    final recommendation = ref.watch(allocationRecommendationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alocação de Ativos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Ver perfil',
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => _buildError(e),
        data: (profile) {
          if (profile == null) {
            return _buildNoProfile(context);
          }
          return assetsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => _buildError(e),
            data: (assets) {
              final totalPatrimony =
                  assets.fold(0.0, (sum, a) => sum + a.currentValue);
              final currentAllocations = <String, double>{};
              for (final asset in assets) {
                final key = asset.category.displayName;
                currentAllocations[key] =
                    (currentAllocations[key] ?? 0) + asset.currentValue;
              }
              if (totalPatrimony > 0) {
                currentAllocations.updateAll(
                    (k, v) => v / totalPatrimony);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(profile.riskProfileName,
                        profile.investmentHorizon),
                    const SizedBox(height: 20),
                    if (recommendation != null) ...[
                      _buildAllocationComparison(
                          recommendation.recommendedAllocations,
                          currentAllocations,
                          totalPatrimony),
                      const SizedBox(height: 20),
                      _buildRationale(recommendation.rationale),
                      const SizedBox(height: 20),
                      _buildRebalancingSuggestions(
                          recommendation.getRebalancingSuggestions(
                              currentAllocations),
                          totalPatrimony),
                      const SizedBox(height: 20),
                      _buildAllocationCards(
                          recommendation.recommendedAllocations,
                          currentAllocations,
                          totalPatrimony),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text('Erro: $e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Perfil não encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete o onboarding para receber recomendações personalizadas de alocação',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('Configurar Perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String riskProfile, int horizon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendação baseada no seu perfil',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  'Perfil $riskProfile • $horizon anos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildAllocationComparison(
    Map<String, double> recommended,
    Map<String, double> current,
    double totalPatrimony,
  ) {
    final allKeys = {...recommended.keys, ...current.keys}.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const SectionHeader(
            title: 'Alocação Atual vs Recomendada',
            subtitle: 'Compare sua carteira com o modelo ideal',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 0.6,
                barGroups: allKeys.asMap().entries.map((entry) {
                  final key = entry.value;
                  final curr = current[key] ?? 0.0;
                  final rec = recommended[key] ?? 0.0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: curr,
                        color: AppColors.secondary.withOpacity(0.7),
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: rec,
                        color: AppColors.primary,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(
                        '${(val * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                      reservedSize: 32,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= allKeys.length) return const SizedBox();
                        final key = allKeys[idx];
                        final short = key.split(' ').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            short,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.secondary.withOpacity(0.7), 'Atual'),
              const SizedBox(width: 20),
              _legendDot(AppColors.primary, 'Recomendada'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0, delay: 200.ms);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildRationale(String rationale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Análise Personalizada',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rationale,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRebalancingSuggestions(
      List<String> suggestions, double totalPatrimony) {
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sua carteira está bem balanceada! Continue monitorando regularmente.',
                style:
                    TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Sugestões de Rebalanceamento',
            subtitle: 'Ajustes para otimizar sua carteira',
          ),
          const SizedBox(height: 8),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildAllocationCards(
    Map<String, double> recommended,
    Map<String, double> current,
    double totalPatrimony,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Detalhamento por Classe',
          subtitle: 'Análise de cada categoria de ativo',
        ),
        const SizedBox(height: 8),
        ...recommended.entries.map((entry) {
          final curr = current[entry.key] ?? 0.0;
          final target = entry.value;
          final gap = (target - curr).abs();
          Color statusColor;
          IconData statusIcon;
          if (gap <= 0.05) {
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle_outline;
          } else if (gap <= 0.15) {
            statusColor = AppColors.warning;
            statusIcon = Icons.warning_amber_outlined;
          } else {
            statusColor = AppColors.error;
            statusIcon = Icons.error_outline;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _allocationStat('Atual', curr, AppColors.secondary),
                    const SizedBox(width: 16),
                    _allocationStat('Meta', target, AppColors.primary),
                    const SizedBox(width: 16),
                    _allocationStat(
                        'Diferença',
                        target - curr,
                        (target - curr) >= 0
                            ? AppColors.warning
                            : AppColors.error),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: curr.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppFormatters.formatBRL(curr * totalPatrimony),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    Text(
                      'Meta: ${AppFormatters.formatBRL(target * totalPatrimony)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05, end: 0, delay: 500.ms);
        }),
      ],
    );
  }

  Widget _allocationStat(String label, double value, Color color) {
    final sign = value > 0 ? '+' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        Text(
          '$sign${AppFormatters.formatPercent(value)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
