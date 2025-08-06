import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final List<String> allergies;
  final String preferredLanguage;
  final bool voiceEnabled;
  final bool darkMode;
  final bool firstLaunch;

  const UserPreferences({
    required this.allergies,
    required this.preferredLanguage,
    required this.voiceEnabled,
    required this.darkMode,
    required this.firstLaunch,
  });

  @override
  List<Object?> get props => [
    allergies,
    preferredLanguage,
    voiceEnabled,
    darkMode,
    firstLaunch,
  ];

  UserPreferences copyWith({
    List<String>? allergies,
    String? preferredLanguage,
    bool? voiceEnabled,
    bool? darkMode,
    bool? firstLaunch,
  }) {
    return UserPreferences(
      allergies: allergies ?? this.allergies,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      darkMode: darkMode ?? this.darkMode,
      firstLaunch: firstLaunch ?? this.firstLaunch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies,
      'preferredLanguage': preferredLanguage,
      'voiceEnabled': voiceEnabled,
      'darkMode': darkMode,
      'firstLaunch': firstLaunch,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      allergies: List<String>.from(json['allergies'] ?? []),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      voiceEnabled: json['voiceEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      firstLaunch: json['firstLaunch'] ?? true,
    );
  }

  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      allergies: [],
      preferredLanguage: 'en',
      voiceEnabled: true,
      darkMode: false,
      firstLaunch: true,
    );
  }
}
