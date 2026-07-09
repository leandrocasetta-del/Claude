import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveHeader extends StatelessWidget {
  final double height;
  final Widget child;
  final Color color;

  const WaveHeader({
    super.key,
    required this.height,
    required this.child,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: color,
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        size.width * 0.5,
        size.height - 20,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - 60,
        size.width,
        size.height - 30,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
