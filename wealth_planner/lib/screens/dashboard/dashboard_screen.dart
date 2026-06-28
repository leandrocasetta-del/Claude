import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/asset.dart';
import '../../providers/assets_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/wealth_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const List<Color> _chartColors = [
    AppColors.chartBlue,
    AppColors.chartGold,
    AppColors.chartGreen,
    AppColors.chartPurple,
    AppColors.chartOrange,
    AppColors.chartCyan,
    AppColors.chartRed,
    AppColors.chartTeal,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final assetsAsync = ref.watch(assetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(assetsProvider);
        },
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, profileAsync),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  assetsAsync.when(
                    loading: () => _buildLoadingState(),
                    error: (e, _) => _buildErrorState(e),
                    data: (assets) => _buildContent(context, assets, ref),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-asset'),
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar Ativo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AsyncValue profileAsync) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.background],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: profileAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (profile) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Olá, ${profile?.name.split(' ').first ?? 'Investidor'} 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Visão geral do seu patrimônio',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile?.name.isNotEmpty == true
                            ? profile!.name[0].toUpperCase()
                            : 'I',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar: $e',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Asset> assets, WidgetRef ref) {
    final totalPatrimony = assets.fold(0.0, (sum, a) => sum + a.currentValue);
    final totalOffshore =
        assets.where((a) => a.isOffshore).fold(0.0, (sum, a) => sum + a.currentValue);
    final totalGain = assets.fold(0.0, (sum, a) => sum + a.unrealizedGain);

    final categoryTotals = <String, double>{};
    for (final asset in assets) {
      final key = asset.category.displayName;
      categoryTotals[key] = (categoryTotals[key] ?? 0) + asset.currentValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalPatrimonyCard(totalPatrimony)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildSummaryCards(totalPatrimony, totalOffshore, totalGain)
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.1, end: 0, delay: 200.ms),
        const SizedBox(height: 24),
        if (assets.isNotEmpty) ...[
          _buildPieChart(categoryTotals, totalPatrimony)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.1, end: 0, delay: 300.ms),
          const SizedBox(height: 24),
        ],
        SectionHeader(
          title: 'Ativos por Categoria',
          subtitle: '${assets.length} ativo${assets.length != 1 ? 's' : ''} cadastrado${assets.length != 1 ? 's' : ''}',
        ),
        if (assets.isEmpty)
          _buildEmptyState(context)
        else
          ...AssetCategory.values.map((category) {
            final categoryAssets =
                assets.where((a) => a.category == category).toList();
            if (categoryAssets.isEmpty) return const SizedBox.shrink();
            return _buildCategorySection(
                context, category, categoryAssets, totalPatrimony);
          }),
      ],
    );
  }

  Widget _buildTotalPatrimonyCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 16, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text(
                'Patrimônio Total',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.formatBRL(total),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Valor consolidado de todos os ativos',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double total, double offshore, double gain) {
    final offshorePercent = total > 0 ? offshore / total : 0.0;
    final gainPercent =
        total > 0 && (total - gain) > 0 ? gain / (total - gain) : 0.0;

    return Row(
      children: [
        Expanded(
          child: WealthSummaryCard(
            title: 'Offshore',
            value: AppFormatters.formatCompactBRL(offshore),
            change: AppFormatters.formatPercent(offshorePercent),
            icon: Icons.language,
            color: AppColors.secondary,
            isPositive: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: WealthSummaryCard(
            title: 'Ganho/Perda',
            value: AppFormatters.formatCompactBRL(gain.abs()),
            change: gain >= 0
                ? '+${AppFormatters.formatPercent(gainPercent)}'
                : AppFormatters.formatPercent(gainPercent),
            icon: gain >= 0 ? Icons.trending_up : Icons.trending_down,
            color: gain >= 0 ? AppColors.success : AppColors.error,
            isPositive: gain >= 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: WealthSummaryCard(
            title: 'Eficiência',
            value: 'Boa',
            icon: Icons.shield_outlined,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, double> categoryTotals, double total) {
    if (categoryTotals.isEmpty) return const SizedBox();

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = entries.asMap().entries.map((e) {
      final color = _chartColors[e.key % _chartColors.length];
      return PieChartSectionData(
        value: e.value.value,
        title: '${(e.value.value / total * 100).toStringAsFixed(0)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const SectionHeader(title: 'Alocação Atual'),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entries.take(6).toList().asMap().entries.map((e) {
                      final color = _chartColors[e.key % _chartColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.value.key,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(e.value.value / total * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, AssetCategory category,
      List<Asset> assets, double totalPatrimony) {
    final categoryTotal = assets.fold(0.0, (s, a) => s + a.currentValue);
    final percentage =
        totalPatrimony > 0 ? categoryTotal / totalPatrimony : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ExpansionTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          category.displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          AppFormatters.formatBRL(categoryTotal),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            AppFormatters.formatPercent(percentage),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        children: assets.map((asset) => _buildAssetTile(context, asset)).toList(),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05, end: 0, delay: 400.ms);
  }

  Widget _buildAssetTile(BuildContext context, Asset asset) {
    final gainColor =
        asset.unrealizedGain >= 0 ? AppColors.success : AppColors.error;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        asset.name,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: asset.broker.isNotEmpty
          ? Text(
              asset.broker,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppFormatters.formatBRL(asset.currentValue),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (asset.acquisitionValue > 0)
            Text(
              '${asset.unrealizedGain >= 0 ? '+' : ''}${asset.unrealizedGainPercent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: gainColor,
              ),
            ),
        ],
      ),
      onLongPress: () => _showAssetOptions(context, asset),
    );
  }

  void _showAssetOptions(BuildContext context, Asset asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer(
        builder: (ctx, ref, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.formatBRL(asset.currentValue),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                title: const Text('Editar ativo'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/add-asset', extra: asset);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Excluir ativo',
                    style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(assetsProvider.notifier)
                      .deleteAsset(asset.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_chart, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum ativo cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione seus investimentos para visualizar a alocação e receber recomendações personalizadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-asset'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar primeiro ativo'),
          ),
        ],
      ),
    );
  }
}
