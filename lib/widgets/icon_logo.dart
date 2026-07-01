import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class IconLogo extends StatefulWidget {
  final double size;
  final double borderRadius;

  const IconLogo({super.key, this.size = 120, this.borderRadius = 28});

  @override
  State<IconLogo> createState() => _IconLogoState();
}

class _IconLogoState extends State<IconLogo> {
  static const _assetPath = 'assets/icon/icon.png';
  bool _precached = false;
  bool _precacheFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached || _precacheFailed) return;
    precacheImage(const AssetImage(_assetPath), context).then((_) {
      if (!mounted) return;
      setState(() => _precached = true);
    }).catchError((Object err, StackTrace st) {
      debugPrint('IconLogo: precache failed for $_assetPath -> $err');
      if (!mounted) return;
      setState(() => _precacheFailed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.asset(
        _assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('IconLogo: asset load failed -> $error');
          return _FallbackLogo(
            size: widget.size,
            borderRadius: widget.borderRadius,
          );
        },
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
