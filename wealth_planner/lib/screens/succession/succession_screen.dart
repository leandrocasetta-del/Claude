import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/succession_plan.dart';
import '../../providers/succession_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/assets_provider.dart';
import '../../widgets/section_header.dart';

class SuccessionScreen extends ConsumerStatefulWidget {
  const SuccessionScreen({super.key});

  @override
  ConsumerState<SuccessionScreen> createState() => _SuccessionScreenState();
}

class _SuccessionScreenState extends ConsumerState<SuccessionScreen> {
  double _itcmdPatrimony = 0;
  String _selectedState = 'SP';
  double _estimatedItcmd = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assets = ref.read(assetsProvider).valueOrNull ?? [];
      final profile = ref.read(profileProvider).valueOrNull;
      final patrimony =
          profile?.totalPatrimony ?? assets.fold<double>(0.0, (s, a) => s + a.currentValue);
      setState(() {
        _itcmdPatrimony = patrimony;
        _calculateItcmd();
      });
    });
  }

  void _calculateItcmd() {
    final state = AppConstants.brazilianStates
        .firstWhere((s) => s['uf'] == _selectedState,
            orElse: () => AppConstants.brazilianStates.first);
    final rate = (state['itcmdRate'] as double);
    setState(() {
      _estimatedItcmd = _itcmdPatrimony * rate;
    });
  }

  Future<void> _toggleItem(SuccessionPlan plan, String field, bool value) async {
    final notifier = ref.read(successionProvider.notifier);
    switch (field) {
      case 'hasWill':
        await notifier.updateField(hasWill: value);
        break;
      case 'holdingCompany':
        await notifier.updateField(holdingCompany: value, itcmdEstimate: _estimatedItcmd);
        break;
      case 'donationInLife':
        await notifier.updateField(donationInLife: value);
        break;
      case 'trustStructure':
        await notifier.updateField(trustStructure: value, itcmdEstimate: _estimatedItcmd);
        break;
      case 'lifeInsurance':
        await notifier.updateField(lifeInsurance: value);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final successionAsync = ref.watch(successionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planejamento Sucessório'),
      ),
      body: successionAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (plan) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(plan).animate().fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: 20),
              _buildItcmdCalculator(),
              const SizedBox(height: 20),
              _buildChecklist(plan),
              const SizedBox(height: 20),
              _buildSavingsSummary(plan),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(SuccessionPlan plan) {
    final percent = plan.completionPercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 8,
            percent: percent,
            center: Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.surfaceVariant,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Proteção Sucessória',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plan.completionItems} de 5 itens completos',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCompletionMessage(percent),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCompletionColor(percent),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCompletionMessage(double percent) {
    if (percent >= 0.8) return 'Excelente proteção patrimonial!';
    if (percent >= 0.6) return 'Boa proteção, continue implementando';
    if (percent >= 0.4) return 'Proteção parcial — há espaço para melhorar';
    if (percent >= 0.2) return 'Proteção básica — atenção necessária';
    return 'Patrimônio desprotegido — aja agora!';
  }

  Color _getCompletionColor(double percent) {
    if (percent >= 0.8) return AppColors.success;
    if (percent >= 0.6) return AppColors.secondary;
    if (percent >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildItcmdCalculator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Calculadora ITCMD',
            subtitle: 'Estime o imposto sobre herança no seu estado',
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _itcmdPatrimony > 0
                ? _itcmdPatrimony.toStringAsFixed(0)
                : '',
            decoration: const InputDecoration(
              labelText: 'Patrimônio a transmitir (R\$)',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                _itcmdPatrimony = double.tryParse(
                        v.replaceAll('.', '').replaceAll(',', '.')) ??
                    0;
                _calculateItcmd();
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: const InputDecoration(
              labelText: 'Estado',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            dropdownColor: AppColors.surface,
            items: AppConstants.brazilianStates.map((s) {
              return DropdownMenuItem<String>(
                value: s['uf'] as String,
                child: Text('${s['uf']} - ${s['name']} (${((s['itcmdRate'] as double) * 100).toStringAsFixed(0)}%)'),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedState = v!;
                _calculateItcmd();
              });
            },
          ),
          const SizedBox(height: 16),
          if (_estimatedItcmd > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ITCMD estimado (sem planejamento)',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        AppFormatters.formatBRL(_estimatedItcmd),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Com planejamento (economia ~40%)',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        AppFormatters.formatBRL(_estimatedItcmd * 0.6),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildChecklist(SuccessionPlan plan) {
    final items = [
      _ChecklistItem(
        icon: '📜',
        title: 'Testamento',
        description:
            'Documento legal que define como seu patrimônio será distribuído',
        field: 'hasWill',
        value: plan.hasWill,
        estimatedCost: 'R\$ 500 - R\$ 3.000',
        taxBenefit: 'Reduz custos de inventário',
        color: AppColors.secondary,
      ),
      _ChecklistItem(
        icon: '🏢',
        title: 'Holding Familiar',
        description:
            'Empresa para concentrar e gerir o patrimônio familiar com mais eficiência',
        field: 'holdingCompany',
        value: plan.holdingCompany,
        estimatedCost: 'R\$ 15.000 - R\$ 50.000',
        taxBenefit: 'Economia de 30-50% no ITCMD',
        color: AppColors.primary,
      ),
      _ChecklistItem(
        icon: '🎁',
        title: 'Doação em Vida',
        description:
            'Transferência de patrimônio aos herdeiros enquanto ainda é possível planejar',
        field: 'donationInLife',
        value: plan.donationInLife,
        estimatedCost: 'ITCMD sobre o valor doado',
        taxBenefit: 'Pode ser mais econômico que herança',
        color: AppColors.success,
      ),
      _ChecklistItem(
        icon: '🔒',
        title: 'Trust / Estrutura Internacional',
        description:
            'Estrutura jurídica internacional para proteção máxima e sucessão sem inventário',
        field: 'trustStructure',
        value: plan.trustStructure,
        estimatedCost: 'US\$ 50.000+',
        taxBenefit: 'Evita inventário, zero ITCMD em alguns casos',
        color: AppColors.chartPurple,
      ),
      _ChecklistItem(
        icon: '💼',
        title: 'Seguro de Vida',
        description:
            'Proteção financeira para herdeiros e forma eficiente de transmissão de recursos',
        field: 'lifeInsurance',
        value: plan.lifeInsurance,
        estimatedCost: 'Variável por cobertura',
        taxBenefit: 'Indenização isenta de IRPF e ITCMD',
        color: AppColors.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Checklist Sucessório',
          subtitle: 'Marque os itens que você já implementou',
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) =>
            _buildChecklistItem(entry.value, plan, entry.key)),
      ],
    );
  }

  Widget _buildChecklistItem(
      _ChecklistItem item, SuccessionPlan plan, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.value
            ? item.color.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.value
              ? item.color.withOpacity(0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: item.value
                            ? item.color
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.value,
                onChanged: (v) => _toggleItem(plan, item.field, v),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return item.color;
                  return AppColors.textMuted;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected))
                    return item.color.withOpacity(0.4);
                  return AppColors.surfaceVariant;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_money,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.estimatedCost,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.savings_outlined,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.taxBenefit,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.success),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(
        begin: -0.05, end: 0, delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildSavingsSummary(SuccessionPlan plan) {
    final savings = plan.estimatedTaxSavings > 0
        ? plan.estimatedTaxSavings
        : _estimatedItcmd * 0.4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.15),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.savings, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text(
                'Economia Tributária Estimada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Com planejamento completo,\nvocê pode economizar:',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              Text(
                AppFormatters.formatBRL(savings > 0 ? savings : _estimatedItcmd * 0.4),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (plan.completionItems < 3) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            const Text(
              '💡 Dica: A combinação de Holding Familiar + Testamento + Seguro de Vida é a estratégia mais eficiente para a maioria dos perfis.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _ChecklistItem {
  final String icon;
  final String title;
  final String description;
  final String field;
  final bool value;
  final String estimatedCost;
  final String taxBenefit;
  final Color color;

  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.field,
    required this.value,
    required this.estimatedCost,
    required this.taxBenefit,
    required this.color,
  });
}
