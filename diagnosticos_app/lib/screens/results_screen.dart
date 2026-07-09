import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'exam_detail_screen.dart';

class _ExamOrder {
  final String pedido;
  final DateTime date;
  final String tipo;
  final List<String> exames;
  final bool hasDetailedReport;
  const _ExamOrder({
    required this.pedido,
    required this.date,
    required this.tipo,
    required this.exames,
    this.hasDetailedReport = false,
  });
}

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  DateTime? _startDate;
  String _examType = 'Cardiologia';
  String _search = '';
  bool _showAll = true;

  final List<_ExamOrder> _orders = [
    _ExamOrder(
      pedido: '34125890',
      date: DateTime(2026, 6, 8),
      tipo: 'Cardiologia',
      exames: [
        'Eletrocardiograma de repouso (12 derivacoes)',
        'Ecocardiograma transtoracico com Doppler',
        'Holter 24 horas',
      ],
      hasDetailedReport: true,
    ),
    _ExamOrder(
      pedido: '33510789',
      date: DateTime(2024, 10, 9),
      tipo: 'Laboratorial',
      exames: ['Hemograma completo', 'Glicemia em jejum', 'TSH'],
    ),
    _ExamOrder(
      pedido: '33489102',
      date: DateTime(2024, 8, 22),
      tipo: 'Laboratorial',
      exames: ['Colesterol total', 'HDL', 'LDL', 'Triglicerides'],
    ),
    _ExamOrder(
      pedido: '33245678',
      date: DateTime(2024, 6, 14),
      tipo: 'Imagem',
      exames: ['Raio-X de torax', 'Ultrassonografia abdominal'],
    ),
    _ExamOrder(
      pedido: '33108234',
      date: DateTime(2024, 3, 5),
      tipo: 'Laboratorial',
      exames: ['Hemograma', 'Vitamina D', 'Ferritina'],
    ),
  ];

  List<_ExamOrder> get _filtered {
    return _orders.where((o) {
      if (!_showAll && _startDate != null && o.date.isBefore(_startDate!)) {
        return false;
      }
      if (o.tipo != _examType) return false;
      if (_search.isEmpty) return true;
      return o.exames.any(
        (e) => e.toLowerCase().contains(_search.toLowerCase()),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Resultado de exames')),
      body: Column(
        children: [
          _FilterCard(
            startDate: _startDate,
            examType: _examType,
            onPickDate: _pickDate,
            onShowAll: () => setState(() {
              _showAll = true;
              _startDate = null;
            }),
            onTypeChanged: (t) => setState(() => _examType = t),
            onSearchChanged: (s) => setState(() => _search = s),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: _filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nenhum resultado encontrado.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _OrderCard(order: _filtered[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _showAll = false;
      });
    }
  }
}

class _FilterCard extends StatelessWidget {
  final DateTime? startDate;
  final String examType;
  final VoidCallback onPickDate;
  final VoidCallback onShowAll;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSearchChanged;

  const _FilterCard({
    required this.startDate,
    required this.examType,
    required this.onPickDate,
    required this.onShowAll,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A partir de',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onPickDate,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate == null ? '' : df.format(startDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.cyan,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onShowAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Exibir tudo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipo de exame',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _TypePill(
              value: examType,
              options: const ['Cardiologia', 'Laboratorial', 'Imagem'],
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: 12),
            const Divider(),
            TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Procurar por exame',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _TypePill({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map(
                    (o) => ListTile(
                      title: Text(o),
                      onTap: () => Navigator.pop(context, o),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cyan,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _ExamOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pedido',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      order.pedido,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Data',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    df.format(order.date),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Laudo completo',
                    onTap: () => order.hasDetailedReport
                        ? _openDetailedReport(context)
                        : _showSnack(context, 'Abrindo laudo completo'),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.show_chart,
                    label: 'Laudo evolutivo',
                    onTap: () => _showSnack(context, 'Abrindo laudo evolutivo'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Exames',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => order.hasDetailedReport
                    ? _openDetailedReport(context)
                    : _showDetails(context),
                child: const Text(
                  'Detalhar',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _openDetailedReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExamDetailScreen()),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pedido ${order.pedido}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              ...order.exames.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.cyan,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondary, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
