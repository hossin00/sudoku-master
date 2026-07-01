import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/glow_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _section('Appearance', [
                _tile(
                  icon: Icons.dark_mode_rounded,
                  color: AppColors.purple,
                  title: 'Dark Mode',
                  subtitle: 'Use a dark color scheme',
                  value: settings.darkMode,
                  onChanged: (_) => notifier.toggleDarkMode(),
                ),
              ]),
              const SizedBox(height: 14),
              _section('Gameplay', [
                _tile(
                  icon: Icons.error_rounded,
                  color: AppColors.error,
                  title: 'Highlight Errors',
                  subtitle: 'Show incorrect numbers in red',
                  value: settings.highlightErrors,
                  onChanged: (_) => notifier.toggleHighlightErrors(),
                ),
                _tile(
                  icon: Icons.timer_rounded,
                  color: AppColors.blue,
                  title: 'Show Timer',
                  subtitle: 'Display elapsed time during play',
                  value: settings.showTimer,
                  onChanged: (_) => notifier.toggleShowTimer(),
                ),
                _tile(
                  icon: Icons.filter_none_rounded,
                  color: AppColors.gold,
                  title: 'Highlight Duplicates',
                  subtitle: 'Highlight matching numbers on board',
                  value: settings.highlightDuplicates,
                  onChanged: (_) => notifier.toggleHighlightDuplicates(),
                ),
                _tile(
                  icon: Icons.edit_note_rounded,
                  color: AppColors.purple,
                  title: 'Auto Notes',
                  subtitle: 'Automatically eliminate note candidates',
                  value: settings.autoNotes,
                  onChanged: (_) => notifier.toggleAutoNotes(),
                ),
              ]),
              const SizedBox(height: 14),
              _section('Sound', [
                _tile(
                  icon: Icons.volume_up_rounded,
                  color: AppColors.success,
                  title: 'Sound Effects',
                  subtitle: 'Enable audio feedback',
                  value: settings.soundEffects,
                  onChanged: (_) => notifier.toggleSoundEffects(),
                ),
              ]),
              const SizedBox(height: 24),
              GlowCard(
                child: Column(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      'Sudoku Master 2026',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlowCard(
          padding: EdgeInsets.zero,
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        activeColor: color,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
