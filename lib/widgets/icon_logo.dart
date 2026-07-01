import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class IconLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const IconLogo({super.key, this.size = 120, this.borderRadius = 28});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _FallbackLogo(
          size: size,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _FallbackLogo({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          '9',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -3,
            shadows: [
              Shadow(
                color: AppColors.gold.withOpacity(0.8),
                blurRadius: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
