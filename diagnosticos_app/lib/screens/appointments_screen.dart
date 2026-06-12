import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'schedule_exam_screen.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appointmentsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Meus agendamentos'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Proximos'),
              Tab(text: 'Historico'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Agendar'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScheduleExamScreen()),
          ),
        ),
        body: async.when(
          data: (items) {
            final upcoming = items
                .where((a) => a.dateTime.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
            final past = items
                .where((a) => a.dateTime.isBefore(DateTime.now()))
                .toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
            return TabBarView(
              children: [
                _AppointmentList(
                  items: upcoming,
                  emptyMsg: 'Nenhum exame agendado.',
                  onRefresh: () async => ref.invalidate(appointmentsProvider),
                  onCancel: (a) async {
                    await ref
                        .read(apiServiceProvider)
                        .cancelAppointment(a.id);
                    ref.invalidate(appointmentsProvider);
                  },
                ),
                _AppointmentList(
                  items: past,
                  emptyMsg: 'Sem historico.',
                  onRefresh: () async => ref.invalidate(appointmentsProvider),
                  onCancel: null,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(appointmentsProvider),
          ),
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> items;
  final String emptyMsg;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Appointment)? onCancel;

  const _AppointmentList({
    required this.items,
    required this.emptyMsg,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    emptyMsg,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AppointmentCard(
                appointment: items[i],
                onCancel: onCancel,
              ),
            ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Future<void> Function(Appointment)? onCancel;
  const _AppointmentCard({required this.appointment, required this.onCancel});

  Color _statusColor() {
    switch (appointment.status) {
      case AppointmentStatus.confirmado:
        return AppColors.success;
      case AppointmentStatus.agendado:
        return AppColors.warning;
      case AppointmentStatus.concluido:
        return AppColors.textSecondary;
      case AppointmentStatus.cancelado:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd/MM/yyyy 'as' HH:mm", 'pt_BR');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(appointment.exam.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.exam.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.exam.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appointment.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _row(Icons.event, df.format(appointment.dateTime)),
          const SizedBox(height: 6),
          _row(Icons.location_on_outlined, appointment.unit),
          const SizedBox(height: 6),
          _row(Icons.person_outline, appointment.doctor),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onCancel!(appointment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Detalhes'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
