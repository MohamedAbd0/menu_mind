import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/language_pack.dart';
import '../repositories/gemma_repository.dart';

@injectable
class TranslateUIUseCase {
  final GemmaRepository repository;

  const TranslateUIUseCase(this.repository);

  Future<LanguagePack> call(TranslateUIParams params) async {
    if (!repository.isModelInitialized) {
      await repository.initializeModel();
    }

    // Check if we have cached translations
    final cachedPack = await repository.loadLanguagePack(params.targetLanguage);
    if (cachedPack != null && !params.forceRefresh) {
      return cachedPack;
    }

    // Translate UI strings
    final translations = await repository.translateUIStrings(
      params.englishStrings,
      params.targetLanguage,
    );

    // Create language pack
    final languagePack = LanguagePack(
      languageCode: params.targetLanguage,
      languageName: _getLanguageName(params.targetLanguage),
      translations: translations,
      lastUpdated: DateTime.now(),
    );

    // Save to cache
    await repository.saveLanguagePack(languagePack);

    return languagePack;
  }

  String _getLanguageName(String languageCode) {
    const languageNames = {
      'en': 'English',
      'ar': 'العربية',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'hi': 'हिन्दी',
      'tr': 'Türkçe',
    };
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }
}

class TranslateUIParams extends Equatable {
  final Map<String, String> englishStrings;
  final String targetLanguage;
  final bool forceRefresh;

  const TranslateUIParams({
    required this.englishStrings,
    required this.targetLanguage,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [englishStrings, targetLanguage, forceRefresh];
}
