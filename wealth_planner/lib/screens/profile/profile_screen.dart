import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/profile_provider.dart';
import '../../models/investor_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/onboarding'),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Erro: $e',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_outlined,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Perfil não configurado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete o onboarding para configurar seu perfil de investidor',
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
            );
          }
          return _buildProfile(context, ref, profile);
        },
      ),
    );
  }

  Widget _buildProfile(
      BuildContext context, WidgetRef ref, InvestorProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAvatarSection(profile)
              .animate()
              .fadeIn()
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Dados Pessoais',
            icon: Icons.person_outline,
            children: [
              _infoRow('Nome', profile.name),
              _infoRow('CPF', AppFormatters.formatCPF(profile.cpf)),
              _infoRow('Data de Nascimento',
                  AppFormatters.formatDate(profile.birthDate)),
              _infoRow('Idade', '${profile.age} anos'),
              _infoRow('Estado Civil', profile.maritalStatus),
              _infoRow('Dependentes', '${profile.dependents}'),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Perfil Financeiro',
            icon: Icons.account_balance_outlined,
            children: [
              _infoRow('Renda Mensal',
                  AppFormatters.formatBRL(profile.monthlyIncome)),
              _infoRow('Patrimônio Total',
                  AppFormatters.formatBRL(profile.totalPatrimony)),
              _infoRow('Perfil de Risco', profile.riskProfileName,
                  valueColor: _getRiskColor(profile.riskProfile)),
              _infoRow('Horizonte de Investimento',
                  '${profile.investmentHorizon} anos'),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          _buildObjectivesSection(profile).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Exposição Internacional',
            icon: Icons.language_outlined,
            children: [
              _infoRow('Ativos no Exterior',
                  profile.hasForeignAssets ? 'Sim' : 'Não',
                  valueColor: profile.hasForeignAssets
                      ? AppColors.secondary
                      : AppColors.textMuted),
              if (profile.hasForeignAssets)
                _infoRow('Valor Estimado',
                    AppFormatters.formatBRL(profile.foreignAssetsValue)),
              _infoRow('País de Residência', profile.residenceCountry),
              _infoRow('Residência Fiscal', profile.taxResidency),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          _buildDangerZone(context, ref).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(InvestorProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'I',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(profile.riskProfile).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Perfil ${profile.riskProfileName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getRiskColor(profile.riskProfile),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatBRL(profile.totalPatrimony),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesSection(InvestorProfile profile) {
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
          const Row(
            children: [
              Icon(Icons.flag_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Objetivos de Investimento',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (profile.objectives.isEmpty)
            const Text(
              'Nenhum objetivo selecionado',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.objectives
                  .map((obj) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          obj,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zona de Perigo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Redefinir o perfil irá apagar todos os seus dados e reiniciar o onboarding.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context, ref),
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              label: const Text(
                'Redefinir Perfil',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Redefinir Perfil'),
        content: const Text(
          'Tem certeza? Todos os dados do perfil serão apagados. Os ativos cadastrados serão mantidos.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileProvider.notifier).clearProfile();
              if (context.mounted) context.go('/onboarding');
            },
            child: const Text('Redefinir'),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(RiskProfile riskProfile) {
    switch (riskProfile) {
      case RiskProfile.conservative:
        return AppColors.success;
      case RiskProfile.moderate:
        return AppColors.warning;
      case RiskProfile.aggressive:
        return AppColors.error;
    }
  }
}
