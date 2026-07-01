class AppSettings {
  final bool darkMode;
  final bool highlightErrors;
  final bool showTimer;
  final bool highlightDuplicates;
  final bool autoNotes;
  final bool soundEffects;

  const AppSettings({
    this.darkMode = true,
    this.highlightErrors = true,
    this.showTimer = true,
    this.highlightDuplicates = true,
    this.autoNotes = false,
    this.soundEffects = true,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? highlightErrors,
    bool? showTimer,
    bool? highlightDuplicates,
    bool? autoNotes,
    bool? soundEffects,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      highlightErrors: highlightErrors ?? this.highlightErrors,
      showTimer: showTimer ?? this.showTimer,
      highlightDuplicates: highlightDuplicates ?? this.highlightDuplicates,
      autoNotes: autoNotes ?? this.autoNotes,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'highlightErrors': highlightErrors,
        'showTimer': showTimer,
        'highlightDuplicates': highlightDuplicates,
        'autoNotes': autoNotes,
        'soundEffects': soundEffects,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        darkMode: json['darkMode'] as bool? ?? true,
        highlightErrors: json['highlightErrors'] as bool? ?? true,
        showTimer: json['showTimer'] as bool? ?? true,
        highlightDuplicates: json['highlightDuplicates'] as bool? ?? true,
        autoNotes: json['autoNotes'] as bool? ?? false,
        soundEffects: json['soundEffects'] as bool? ?? true,
      );
}
