import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppLogo extends StatefulWidget {
  final double size;

  const AppLogo({super.key, this.size = 96});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(widget.size * 0.22),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withOpacity(0.3 + 0.2 * t),
                blurRadius: 30 + 12 * t,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.purple.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '9',
              style: TextStyle(
                fontSize: widget.size * 0.55,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: AppColors.gold.withOpacity(0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
