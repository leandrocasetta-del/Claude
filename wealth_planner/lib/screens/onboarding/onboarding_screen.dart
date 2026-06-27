import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/investor_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/risk_profile_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Step 2 - Personal info
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  DateTime _birthDate = DateTime(1985, 1, 1);
  String _maritalStatus = 'Solteiro(a)';
  int _dependents = 0;

  // Step 3 - Financial profile
  final _incomeController = TextEditingController();
  final _patrimonyController = TextEditingController();
  RiskProfile _riskProfile = RiskProfile.moderate;
  int _investmentHorizon = 10;

  // Step 4 - Objectives
  final Set<String> _selectedObjectives = {};

  // Step 5 - International
  bool _hasForeignAssets = false;
  final _foreignAssetsController = TextEditingController();
  String _residenceCountry = 'Brasil';
  String _taxResidency = 'Brasil';

  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _incomeController.dispose();
    _patrimonyController.dispose();
    _foreignAssetsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: 400.ms,
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: 400.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  double _parseDouble(String text) {
    final cleaned = text
        .replaceAll('R\$', '')
        .replaceAll('US\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final profile = InvestorProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim().isEmpty
            ? 'Investidor'
            : _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        birthDate: _birthDate,
        maritalStatus: _maritalStatus,
        dependents: _dependents,
        monthlyIncome: _parseDouble(_incomeController.text),
        totalPatrimony: _parseDouble(_patrimonyController.text),
        riskProfile: _riskProfile,
        investmentHorizon: _investmentHorizon,
        objectives: _selectedObjectives.toList(),
        hasMinors: _dependents > 0,
        hasForeignAssets: _hasForeignAssets,
        foreignAssetsValue: _parseDouble(_foreignAssetsController.text),
        residenceCountry: _residenceCountry,
        taxResidency: _taxResidency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(profileProvider.notifier).saveProfile(profile);
      if (mounted) {
        context.go('/home/dashboard');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomeStep(),
                  _buildPersonalInfoStep(),
                  _buildFinancialProfileStep(),
                  _buildObjectivesStep(),
                  _buildInternationalStep(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passo ${_currentPage + 1} de $_totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '${((_currentPage + 1) / _totalPages * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.account_balance,
              size: 60,
              color: AppColors.primary,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          const Text(
            'Bem-vindo ao\nWealthPlanner',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 300.ms),
          const SizedBox(height: 16),
          const Text(
            'Seu assistente de planejamento patrimonial para investidores sofisticados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 500.ms),
          const SizedBox(height: 48),
          _buildFeatureItem(
              Icons.pie_chart_outline, 'Alocação inteligente de ativos'),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.language, 'Planejamento offshore otimizado'),
          const SizedBox(height: 16),
          _buildFeatureItem(
              Icons.family_restroom, 'Estratégias de sucessão familiar'),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.shield_outlined, 'Proteção patrimonial'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0, delay: 600.ms);
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Dados Pessoais',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nos conte um pouco sobre você',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cpfController,
            decoration: const InputDecoration(
              labelText: 'CPF',
              hintText: '000.000.000-00',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CpfInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data de Nascimento',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year}',
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _maritalStatus,
            decoration: const InputDecoration(
              labelText: 'Estado Civil',
              prefixIcon: Icon(Icons.favorite_outline),
            ),
            dropdownColor: AppColors.surface,
            items: AppConstants.maritalStatuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _maritalStatus = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Número de dependentes',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _dependents > 0
                          ? () => setState(() => _dependents--)
                          : null,
                      color: AppColors.primary,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_dependents',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => setState(() => _dependents++),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Perfil Financeiro',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informações sobre seu patrimônio e perfil de risco',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _incomeController,
            decoration: const InputDecoration(
              labelText: 'Renda Mensal (R\$)',
              hintText: 'R\$ 0,00',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _patrimonyController,
            decoration: const InputDecoration(
              labelText: 'Patrimônio Total (R\$)',
              hintText: 'R\$ 0,00',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Horizonte de Investimento',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_investmentHorizon anos',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _investmentHorizon.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_investmentHorizon anos',
            onChanged: (v) =>
                setState(() => _investmentHorizon = v.toInt()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1 ano', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('15 anos', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('30 anos', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Perfil de Risco',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...AppConstants.riskProfiles.map((profile) {
            final rp = RiskProfile.values.firstWhere(
              (r) => r.name == profile['id'],
              orElse: () => RiskProfile.moderate,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RiskProfileCard(
                id: profile['id'] as String,
                name: profile['name'] as String,
                description: profile['description'] as String,
                expectedReturn: profile['expectedReturn'] as String,
                volatility: profile['volatility'] as String,
                icon: profile['icon'] as String,
                isSelected: _riskProfile == rp,
                onTap: () => setState(() => _riskProfile = rp),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildObjectivesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Objetivos de Investimento',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecione todos que se aplicam ao seu momento atual',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.investmentObjectives.map((obj) {
              final selected = _selectedObjectives.contains(obj);
              return FilterChip(
                label: Text(obj),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedObjectives.add(obj);
                    } else {
                      _selectedObjectives.remove(obj);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.cardBorder,
                ),
                backgroundColor: AppColors.surfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              );
            }).toList(),
          ),
          if (_selectedObjectives.isEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecione pelo menos um objetivo para personalizar suas recomendações',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInternationalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Exposição Internacional',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informe sobre seus ativos e vínculos internacionais',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: AppColors.secondary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Possui ativos no exterior?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Contas, investimentos ou imóveis fora do Brasil',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hasForeignAssets,
                  onChanged: (v) =>
                      setState(() => _hasForeignAssets = v),
                ),
              ],
            ),
          ),
          if (_hasForeignAssets) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _foreignAssetsController,
              decoration: const InputDecoration(
                labelText: 'Valor aproximado (R\$)',
                hintText: 'R\$ 0,00',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _residenceCountry,
            decoration: const InputDecoration(
              labelText: 'País de Residência',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            dropdownColor: AppColors.surface,
            items: AppConstants.countries
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) =>
                setState(() => _residenceCountry = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _taxResidency,
            decoration: const InputDecoration(
              labelText: 'Residência Fiscal',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            dropdownColor: AppColors.surface,
            items: AppConstants.countries
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) =>
                setState(() => _taxResidency = v!),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.secondary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Investidores com ativos no exterior acima de US\$ 1 milhão devem declarar ao Banco Central (CBE) anualmente.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _prevPage,
              child: const Text('Voltar'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSaving ? null : _nextPage,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Text(
                    _currentPage == _totalPages - 1
                        ? 'Começar'
                        : 'Continuar',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final sb = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) sb.write('.');
      if (i == 9) sb.write('-');
      sb.write(digits[i]);
    }

    final formatted = sb.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
