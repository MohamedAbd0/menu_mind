import '../../domain/entities/language_pack.dart';

// part 'language_pack_model.g.dart';
// TODO: Enable when build_runner is set up properly

// @HiveType(typeId: 1)
class LanguagePackModel {
  // @HiveField(0)
  final String languageCode;

  // @HiveField(1)
  final String languageName;

  // @HiveField(2)
  final Map<String, String> translations;

  // @HiveField(3)
  final DateTime lastUpdated;

  LanguagePackModel({
    required this.languageCode,
    required this.languageName,
    required this.translations,
    required this.lastUpdated,
  });

  factory LanguagePackModel.fromEntity(LanguagePack languagePack) {
    return LanguagePackModel(
      languageCode: languagePack.languageCode,
      languageName: languagePack.languageName,
      translations: languagePack.translations,
      lastUpdated: languagePack.lastUpdated,
    );
  }

  LanguagePack toEntity() {
    return LanguagePack(
      languageCode: languageCode,
      languageName: languageName,
      translations: translations,
      lastUpdated: lastUpdated,
    );
  }

  factory LanguagePackModel.fromJson(Map<String, dynamic> json) {
    return LanguagePackModel(
      languageCode: json['languageCode'] ?? 'en',
      languageName: json['languageName'] ?? 'English',
      translations: Map<String, String>.from(json['translations'] ?? {}),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'translations': translations,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
