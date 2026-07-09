import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'results_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Column(
            children: [
              const _UserHeader(
                name: 'Leandro Casetta',
                prontuario: '21356284',
                birthDate: '11/04/1983',
              ),
              Expanded(
                child: Container(
                  color: AppColors.primary,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _BottomWavePainter()),
                      ),
                      ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        children: [
                          _MenuCard(
                            icon: Icons.assignment_turned_in_outlined,
                            label: 'Resultado de exames',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResultsScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            icon: Icons.calendar_today_outlined,
                            label: 'Meus agendamentos',
                            onTap: () => _snack(context, 'Meus agendamentos'),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            icon: Icons.vaccines_outlined,
                            label: 'Vacinas',
                            onTap: () =>
                                _snack(context, 'Carteira de vacinacao'),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            icon: Icons.receipt_long_outlined,
                            label: 'Extrato de conta particular',
                            onTap: () => _snack(context, 'Extrato de conta'),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            icon: Icons.volunteer_activism_outlined,
                            label: 'Doe aqui',
                            onTap: () => _snack(context, 'Faca uma doacao'),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            icon: Icons.handshake_outlined,
                            label: 'Acesso temporario',
                            onTap: () =>
                                _snack(context, 'Compartilhar acesso'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.whatsapp,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'suporte\ntecnico',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => _showSettings(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final bioAvail = ref.watch(biometricAvailableProvider);
                final bioOn = ref.watch(biometricEnabledProvider);
                final notifOn = ref.watch(notificationsEnabledProvider);
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notificacoes'),
                      subtitle: const Text('Lembretes de exame'),
                      value: notifOn.value ?? true,
                      activeColor: AppColors.primary,
                      onChanged: (v) async {
                        await ref
                            .read(notificationServiceProvider)
                            .setEnabled(v);
                        ref.invalidate(notificationsEnabledProvider);
                      },
                    ),
                    if (bioAvail.value == true)
                      SwitchListTile(
                        title: const Text('Login por biometria'),
                        subtitle: const Text('Use digital ou face para entrar'),
                        value: bioOn.value ?? false,
                        activeColor: AppColors.primary,
                        onChanged: (v) async {
                          if (v) {
                            final authed = await ref
                                .read(authServiceProvider)
                                .authenticateWithBiometric();
                            if (authed) {
                              await ref
                                  .read(authServiceProvider)
                                  .setBiometricEnabled(true);
                            }
                          } else {
                            await ref
                                .read(authServiceProvider)
                                .setBiometricEnabled(false);
                          }
                          ref.invalidate(biometricEnabledProvider);
                        },
                      ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.accent),
              title: const Text(
                'Sair',
                style: TextStyle(color: AppColors.accent),
              ),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String name;
  final String prontuario;
  final String birthDate;

  const _UserHeader({
    required this.name,
    required this.prontuario,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.secondary,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prontuario,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Prontuario',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          birthDate,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Data de nascimento',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Icon(icon, color: AppColors.secondary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.background;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 80)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height - 150,
        size.width * 0.6,
        size.height - 90,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height - 50,
        size.width,
        size.height - 80,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
