import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ScheduleExamScreen extends StatefulWidget {
  const ScheduleExamScreen({super.key});

  @override
  State<ScheduleExamScreen> createState() => _ScheduleExamScreenState();
}

class _ScheduleExamScreenState extends State<ScheduleExamScreen> {
  String _category = MockData.categories.first;
  ExamType? _selectedExam;
  Unit? _selectedUnit;
  DateTime? _selectedDate;
  String? _selectedTime;

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
    final filteredExams = MockData.examTypes
        .where((e) => e.category == _category)
        .toList();

    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agendar exame')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _StepLabel(step: 1, title: 'Categoria'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MockData.categories
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
                      color: _category == c ? Colors.white : AppColors.primary,
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
          ...filteredExams.map(
            (e) => _ExamOption(
              exam: e,
              selected: _selectedExam?.id == e.id,
              onTap: () => setState(() => _selectedExam = e),
            ),
          ),
          const SizedBox(height: 24),
          const _StepLabel(step: 3, title: 'Unidade'),
          const SizedBox(height: 8),
          ...MockData.units.map(
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
                      onSelected: (_) => setState(() => _selectedTime = t),
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
            onPressed: _canConfirm() ? _confirm : null,
            child: const Text('Confirmar agendamento'),
          ),
          const SizedBox(height: 24),
        ],
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

  void _confirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Agendamento confirmado'),
        content: Text(
          '${_selectedExam!.name}\n${_selectedUnit!.name}\n'
          '${DateFormat('dd/MM/yyyy').format(_selectedDate!)} as $_selectedTime',
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
