import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'storage_provider.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._ref) : super(_ref.read(storageServiceProvider).loadSettings());

  final Ref _ref;

  Future<void> update(AppSettings newSettings) async {
    state = newSettings;
    await _ref.read(storageServiceProvider).saveSettings(newSettings);
  }

  void toggleDarkMode() => update(state.copyWith(darkMode: !state.darkMode));
  void toggleHighlightErrors() => update(state.copyWith(highlightErrors: !state.highlightErrors));
  void toggleShowTimer() => update(state.copyWith(showTimer: !state.showTimer));
  void toggleHighlightDuplicates() =>
      update(state.copyWith(highlightDuplicates: !state.highlightDuplicates));
  void toggleAutoNotes() => update(state.copyWith(autoNotes: !state.autoNotes));
  void toggleSoundEffects() => update(state.copyWith(soundEffects: !state.soundEffects));
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});
