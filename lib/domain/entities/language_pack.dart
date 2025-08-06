import 'package:equatable/equatable.dart';

class LanguagePack extends Equatable {
  final String languageCode;
  final String languageName;
  final Map<String, String> translations;
  final DateTime lastUpdated;

  const LanguagePack({
    required this.languageCode,
    required this.languageName,
    required this.translations,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    languageCode,
    languageName,
    translations,
    lastUpdated,
  ];

  LanguagePack copyWith({
    String? languageCode,
    String? languageName,
    Map<String, String>? translations,
    DateTime? lastUpdated,
  }) {
    return LanguagePack(
      languageCode: languageCode ?? this.languageCode,
      languageName: languageName ?? this.languageName,
      translations: translations ?? this.translations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String translate(String key) {
    return translations[key] ?? key;
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'translations': translations,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LanguagePack.fromJson(Map<String, dynamic> json) {
    return LanguagePack(
      languageCode: json['languageCode'] ?? 'en',
      languageName: json['languageName'] ?? 'English',
      translations: Map<String, String>.from(json['translations'] ?? {}),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
