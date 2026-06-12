import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';
import '../widgets/section_header.dart';
import 'schedule_exam_screen.dart';
import 'preparation_screen.dart';
import 'results_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProvider);
          ref.invalidate(appointmentsProvider);
        },
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              userAsync.when(
                data: (user) => _Header(name: user.name.split(' ').first),
                loading: () => const _Header(name: '...'),
                error: (e, _) => _Header(name: 'Visitante'),
              ),
              const SizedBox(height: 16),
              appointmentsAsync.when(
                data: (list) {
                  final next = list
                      .where((a) => a.dateTime.isAfter(DateTime.now()))
                      .toList()
                    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                  if (next.isEmpty) return const SizedBox.shrink();
                  return _NextAppointmentCard(appointment: next.first);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _LoadingCard(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ErrorBanner(message: e.toString()),
                ),
              ),
              const SectionHeader(title: 'Servicos'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    ServiceCard(
                      icon: Icons.add_circle_outline,
                      label: 'Agendar exame',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScheduleExamScreen(),
                        ),
                      ),
                    ),
                    ServiceCard(
                      icon: Icons.description_outlined,
                      label: 'Meus resultados',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResultsScreen(),
                        ),
                      ),
                    ),
                    ServiceCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Preparos',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PreparationScreen(),
                        ),
                      ),
                    ),
                    ServiceCard(
                      icon: Icons.qr_code_scanner_outlined,
                      label: 'Check-in',
                      onTap: () => _snack(context, 'Check-in via QR Code'),
                    ),
                    ServiceCard(
                      icon: Icons.local_hospital_outlined,
                      label: 'Convenios',
                      onTap: () => _snack(context, 'Convenios aceitos'),
                    ),
                    ServiceCard(
                      icon: Icons.payment_outlined,
                      label: 'Pagamentos',
                      onTap: () => _snack(context, 'Pagamentos'),
                    ),
                    ServiceCard(
                      icon: Icons.support_agent_outlined,
                      label: 'Atendimento',
                      onTap: () => _snack(context, 'Fale com a gente'),
                    ),
                    ServiceCard(
                      icon: Icons.more_horiz,
                      label: 'Mais',
                      onTap: () => _snack(context, 'Mais servicos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Destaques',
                actionLabel: 'Ver todos',
                onAction: () {},
              ),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _HighlightCard(
                      title: 'Check-up Cardiologico',
                      subtitle: 'Pacote completo a partir de R\$ 590',
                      color: AppColors.primary,
                      icon: Icons.favorite_outline,
                    ),
                    SizedBox(width: 12),
                    _HighlightCard(
                      title: 'Resultados pelo app',
                      subtitle: 'Disponiveis em ate 24h',
                      color: AppColors.accent,
                      icon: Icons.cloud_download_outlined,
                    ),
                    SizedBox(width: 12),
                    _HighlightCard(
                      title: 'Vacinas',
                      subtitle: 'Calendario completo disponivel',
                      color: AppColors.success,
                      icon: Icons.vaccines_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(
              name.isEmpty ? '?' : name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ola,',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd 'de' MMMM 'as' HH:mm", 'pt_BR');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROXIMO EXAME',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.exam.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                df.format(appointment.dateTime),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                appointment.unit,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _HighlightCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
