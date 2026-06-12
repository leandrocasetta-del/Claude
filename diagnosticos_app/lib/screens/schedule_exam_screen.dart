import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class ScheduleExamScreen extends ConsumerStatefulWidget {
  const ScheduleExamScreen({super.key});

  @override
  ConsumerState<ScheduleExamScreen> createState() =>
      _ScheduleExamScreenState();
}

class _ScheduleExamScreenState extends ConsumerState<ScheduleExamScreen> {
  String _category = 'Imagem';
  ExamType? _selectedExam;
  Unit? _selectedUnit;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _submitting = false;

  final List<String> _timeSlots = const [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examTypesProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agendar exame')),
      body: examsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (allExams) {
          final categories =
              allExams.map((e) => e.category).toSet().toList()..sort();
          if (!categories.contains(_category) && categories.isNotEmpty) {
            _category = categories.first;
          }
          final filtered =
              allExams.where((e) => e.category == _category).toList();

          return unitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (units) => ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _StepLabel(step: 1, title: 'Categoria'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories
                      .map(
                        (c) => ChoiceChip(
                          label: Text(c),
                          selected: _category == c,
                          onSelected: (_) => setState(() {
                            _category = c;
                            _selectedExam = null;
                          }),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _category == c
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                const _StepLabel(step: 2, title: 'Exame'),
                const SizedBox(height: 8),
                ...filtered.map(
                  (e) => _ExamOption(
                    exam: e,
                    selected: _selectedExam?.id == e.id,
                    onTap: () => setState(() => _selectedExam = e),
                  ),
                ),
                const SizedBox(height: 24),
                const _StepLabel(step: 3, title: 'Unidade'),
                const SizedBox(height: 8),
                ...units.map(
                  (u) => _UnitOption(
                    unit: u,
                    selected: _selectedUnit?.id == u.id,
                    onTap: () => setState(() => _selectedUnit = u),
                  ),
                ),
                const SizedBox(height: 24),
                const _StepLabel(step: 4, title: 'Data e horario'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      _selectedDate == null
                          ? 'Escolher data'
                          : df.format(_selectedDate!),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickDate,
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots
                        .map(
                          (t) => ChoiceChip(
                            label: Text(t),
                            selected: _selectedTime == t,
                            onSelected: (_) =>
                                setState(() => _selectedTime = t),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _selectedTime == t
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.divider),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _canConfirm() && !_submitting ? _confirm : null,
                  child: _submitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Confirmar agendamento'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canConfirm() =>
      _selectedExam != null &&
      _selectedUnit != null &&
      _selectedDate != null &&
      _selectedTime != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      final parts = _selectedTime!.split(':');
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      await ref.read(apiServiceProvider).createAppointment(
            examId: _selectedExam!.id,
            unit: _selectedUnit!.name,
            dateTime: dt,
          );

      await ref.read(notificationServiceProvider).scheduleExamReminder(
            id: dt.millisecondsSinceEpoch ~/ 1000,
            examName: _selectedExam!.name,
            unit: _selectedUnit!.name,
            examDateTime: dt,
          );

      ref.invalidate(appointmentsProvider);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Agendamento confirmado'),
          content: Text(
            '${_selectedExam!.name}\n${_selectedUnit!.name}\n'
            '${DateFormat('dd/MM/yyyy').format(_selectedDate!)} as $_selectedTime\n\n'
            'Voce recebera um lembrete 24h antes do exame.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _StepLabel extends StatelessWidget {
  final int step;
  final String title;
  const _StepLabel({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary,
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ExamOption extends StatelessWidget {
  final ExamType exam;
  final bool selected;
  final VoidCallback onTap;
  const _ExamOption({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(exam.icon, color: AppColors.primary),
        title: Text(
          exam.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Duracao: ${exam.durationMinutes} min'),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  final Unit unit;
  final bool selected;
  final VoidCallback onTap;
  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.local_hospital_outlined,
          color: AppColors.primary,
        ),
        title: Text(
          unit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${unit.distanceKm.toStringAsFixed(1)} km'),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}
