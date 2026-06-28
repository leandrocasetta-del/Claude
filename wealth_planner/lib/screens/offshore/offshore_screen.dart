import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/offshore_structure.dart';
import '../../providers/assets_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/section_header.dart';

class OffshoreScreen extends ConsumerWidget {
  const OffshoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);
    final profileAsync = ref.watch(profileProvider);
    final structures = OffshoreStructure.predefinedStructures();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planejamento Offshore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            assetsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('Erro: $e',
                  style: const TextStyle(color: AppColors.error)),
              data: (assets) {
                final totalOffshore = assets
                    .where((a) => a.isOffshore)
                    .fold(0.0, (s, a) => s + a.currentValue);
                final total = assets.fold(0.0, (s, a) => s + a.currentValue);

                return _buildOffshoreHeader(totalOffshore, total, context);
              },
            ),
            const SizedBox(height: 24),
            profileAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (profile) => profile != null
                  ? _buildRecommendedStructure(profile.totalPatrimony, structures)
                  : const SizedBox(),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Estruturas Disponíveis',
              subtitle: 'Principais opções para investidores brasileiros',
            ),
            const SizedBox(height: 12),
            ...structures.asMap().entries.map((entry) =>
                _buildStructureCard(context, entry.value, entry.key)),
            const SizedBox(height: 24),
            _buildTaxInfoCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOffshoreHeader(
      double totalOffshore, double total, BuildContext context) {
    final hasOffshore = totalOffshore > 0;
    final percent = total > 0 ? totalOffshore / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasOffshore
              ? [
                  AppColors.secondary.withOpacity(0.15),
                  AppColors.surface,
                ]
              : [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasOffshore
              ? AppColors.secondary.withOpacity(0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌍', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ativos no Exterior',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      hasOffshore
                          ? AppFormatters.formatBRL(totalOffshore)
                          : 'Nenhum ativo offshore',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: hasOffshore
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasOffshore)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppFormatters.formatPercent(percent),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasOffshore) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meta recomendada: 20-30% do patrimônio em ativos internacionais',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ] else ...[
            const Text(
              'Proteja seu patrimônio com diversificação geográfica. Adicione ativos internacionais para reduzir riscos de concentração em uma única economia.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/add-asset'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar ativo offshore'),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildRecommendedStructure(
      double patrimony, List<OffshoreStructure> structures) {
    OffshoreStructure? recommended;
    String reason = '';

    if (patrimony >= 10000000) {
      recommended = structures.firstWhere(
          (s) => s.type == OffshoreStructureType.trust,
          orElse: () => structures.first);
      reason = 'Para patrimônios acima de R\$ 10M, um Trust oferece máxima proteção.';
    } else if (patrimony >= 5000000) {
      recommended = structures.firstWhere(
          (s) => s.type == OffshoreStructureType.holdingCayman,
          orElse: () => structures.first);
      reason = 'Para patrimônios acima de R\$ 5M, uma Holding Cayman é ideal.';
    } else if (patrimony >= 2000000) {
      recommended = structures.firstWhere(
          (s) => s.type == OffshoreStructureType.holdingBVI,
          orElse: () => structures.first);
      reason = 'A Holding BVI oferece excelente custo-benefício para seu nível patrimonial.';
    } else {
      recommended = structures.firstWhere(
          (s) => s.type == OffshoreStructureType.bankAccount,
          orElse: () => structures.first);
      reason =
          'Uma conta bancária internacional é o primeiro passo para diversificação.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Recomendação para Seu Patrimônio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(recommended.flagEmoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommended.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      recommended.jurisdiction,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStructureCard(
      BuildContext context, OffshoreStructure structure, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(
            surface: AppColors.surface,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Text(structure.flagEmoji,
              style: const TextStyle(fontSize: 28)),
          title: Text(
            structure.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                structure.jurisdiction,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _costChip(
                      'Setup: ${AppFormatters.formatCompactBRL(structure.estimatedSetupCost)}',
                      AppColors.warning),
                  const SizedBox(width: 8),
                  _costChip(
                      'Anual: ${AppFormatters.formatCompactBRL(structure.annualMaintenanceCost)}',
                      AppColors.secondary),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.divider),
                  _buildBenefitsSection(
                      '✅ Benefícios Fiscais', structure.taxBenefits, AppColors.success),
                  const SizedBox(height: 12),
                  _buildBenefitsSection(
                      '👍 Vantagens', structure.pros, AppColors.secondary),
                  const SizedBox(height: 12),
                  _buildBenefitsSection(
                      '⚠️ Desvantagens', structure.cons, AppColors.warning),
                  const SizedBox(height: 12),
                  _buildBenefitsSection(
                      '📋 Requisitos', structure.requirements, AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Mínimo recomendado: ${AppFormatters.formatBRL(structure.recommendedMinAssets)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(
        begin: 0.05, end: 0, delay: Duration(milliseconds: 100 * index));
  }

  Widget _costChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBenefitsSection(
      String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTaxInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Obrigações Fiscais no Brasil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _taxItem(
            'IRPF sobre Rendimentos Offshore',
            'Rendimentos auferidos no exterior são tributados em IRPF conforme tabela progressiva (até 27,5%).',
            AppColors.warning,
          ),
          const SizedBox(height: 8),
          _taxItem(
            'Declaração CBE (BACEN)',
            'Ativos no exterior acima de US\$ 1M devem ser declarados ao Banco Central anualmente.',
            AppColors.secondary,
          ),
          const SizedBox(height: 8),
          _taxItem(
            'GCAP e Variação Cambial',
            'Ganhos de capital e variação cambial são tributados em 15-22,5% (conforme faixa de ganho).',
            AppColors.error,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _taxItem(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 6),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
