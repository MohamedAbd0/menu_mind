import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/language_pack.dart';
import '../../domain/usecases/translate_ui_usecase.dart';
import '../../data/datasources/local_storage_datasource.dart';

// States
abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final Map<String, LanguagePack> languagePacks;
  final String currentLanguage;

  const TranslationLoaded({
    required this.languagePacks,
    required this.currentLanguage,
  });

  @override
  List<Object?> get props => [languagePacks, currentLanguage];
}

class TranslationError extends TranslationState {
  final String message;

  const TranslationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class TranslationCubit extends Cubit<TranslationState> {
  final TranslateUIUseCase _translateUIUseCase;
  final LocalStorageDataSource _localStorageDataSource;

  TranslationCubit({
    required TranslateUIUseCase translateUIUseCase,
    required LocalStorageDataSource localStorageDataSource,
  })  : _translateUIUseCase = translateUIUseCase,
        _localStorageDataSource = localStorageDataSource,
        super(TranslationInitial());

  Map<String, LanguagePack> get languagePacks {
    if (state is TranslationLoaded) {
      return (state as TranslationLoaded).languagePacks;
    }
    return {};
  }

  String get currentLanguage {
    if (state is TranslationLoaded) {
      return (state as TranslationLoaded).currentLanguage;
    }
    return 'en';
  }

  bool get isLoading => state is TranslationLoading;
  LanguagePack? get currentLanguagePack => languagePacks[currentLanguage];

  // Supported languages with their display names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'hi': 'हिन्दी',
    'tr': 'Türkçe',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
  };

  // RTL languages
  static const Set<String> rtlLanguages = {'ar', 'he', 'fa', 'ur'};

  bool get isRTL => rtlLanguages.contains(currentLanguage);

  Future<void> initializeTranslations() async {
    try {
      emit(TranslationLoading());

      // Load cached language packs from local storage
      // final cachedPacks = await _loadCachedLanguagePacks();

      // Always refresh English pack to ensure new translations are included
      final cachedPacks = <String, LanguagePack>{};
      cachedPacks['en'] = _createDefaultEnglishPack();

      emit(
        TranslationLoaded(languagePacks: cachedPacks, currentLanguage: 'en'),
      );
    } catch (e) {
      emit(TranslationError(e.toString()));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (currentLanguage == languageCode) return;

    try {
      emit(TranslationLoading());

      final currentPacks = Map<String, LanguagePack>.from(languagePacks);

      // Load language pack if not already loaded
      if (!currentPacks.containsKey(languageCode)) {
        await _loadLanguagePack(languageCode, currentPacks);
      }

      // Force reload the language pack to ensure fresh translations with timeout
      if (currentPacks.containsKey(languageCode)) {
        debugPrint(
            '🔄 Force refreshing language pack for $languageCode from Gemma AI');

        await _loadLanguagePack(languageCode, currentPacks, forceRefresh: true)
            .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            debugPrint('⚠️ Language pack loading timeout for $languageCode');
            throw Exception('Translation timeout - please try again');
          },
        );
      }

      emit(
        TranslationLoaded(
          languagePacks: currentPacks,
          currentLanguage: languageCode,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error changing language to $languageCode: $e');
      emit(TranslationError('Failed to change language: ${e.toString()}'));
    }
  }

  Future<void> _loadLanguagePack(
    String languageCode,
    Map<String, LanguagePack> currentPacks, {
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get from local storage first (unless forcing refresh)
      if (!forceRefresh) {
        final cachedPack = await _localStorageDataSource.getLanguagePack(
          languageCode,
        );
        if (cachedPack != null) {
          currentPacks[languageCode] = cachedPack;
          return;
        }
      }

      // If not cached or forcing refresh, use the translation service to generate
      if (forceRefresh) {
        debugPrint(
            '🚀 Fetching fresh translations for $languageCode from Gemma AI');
      }
      final params = TranslateUIParams(
        targetLanguage: languageCode,
        englishStrings: _getUIElementsToTranslate(),
        forceRefresh: forceRefresh,
      );

      final languagePack = await _translateUIUseCase(params);
      currentPacks[languageCode] = languagePack;

      // Cache the language pack
      await _localStorageDataSource.saveLanguagePack(languagePack);
    } catch (e) {
      debugPrint('Error loading language pack for $languageCode: $e');
      // Fallback to English if available
      if (languageCode != 'en' && currentPacks.containsKey('en')) {
        currentPacks[languageCode] = currentPacks['en']!;
      }
    }
  }

  Future<Map<String, LanguagePack>> _loadCachedLanguagePacks() async {
    try {
      final cachedPacks = await _localStorageDataSource.getAllLanguagePacks();
      final packMap = <String, LanguagePack>{};
      for (final pack in cachedPacks) {
        packMap[pack.languageCode] = pack;
      }
      return packMap;
    } catch (e) {
      debugPrint('Error loading cached language packs: $e');
      return {};
    }
  }

  String translate(String key) {
    final pack = currentLanguagePack;
    if (pack == null) {
      return key; // Return key if no translation available
    }
    return pack.translations[key] ?? key;
  }

  String translateWithFallback(String key, String fallback) {
    final translation = translate(key);
    return translation == key ? fallback : translation;
  }

  /// Force refresh all translations for the current language
  Future<void> refreshCurrentLanguage() async {
    if (currentLanguage.isNotEmpty) {
      await changeLanguage(currentLanguage);
    }
  }

  /// Check if a translation key exists in the current language pack
  bool hasTranslation(String key) {
    final pack = currentLanguagePack;
    if (pack == null) return false;
    return pack.translations.containsKey(key);
  }

  /// Clear cached translations for a specific language
  Future<void> clearCachedTranslations(String languageCode) async {
    try {
      await _localStorageDataSource.deleteLanguagePack(languageCode);
      debugPrint('🗑️ Cleared cached translations for $languageCode');
    } catch (e) {
      debugPrint('❌ Failed to clear cached translations for $languageCode: $e');
    }
  }

  /// Clear all cached translations
  Future<void> clearAllCachedTranslations() async {
    try {
      // Note: This would require implementing a method in LocalStorageDataSource
      // For now, we'll just log it
      debugPrint('🗑️ Clearing all cached translations...');
    } catch (e) {
      debugPrint('❌ Failed to clear all cached translations: $e');
    }
  }

  LanguagePack _createDefaultEnglishPack() {
    return LanguagePack(
      languageCode: 'en',
      languageName: 'English',
      lastUpdated: DateTime.now(),
      translations: _getDefaultEnglishTranslations(),
    );
  }

  Map<String, String> _getUIElementsToTranslate() {
    return _getDefaultEnglishTranslations();
  }

  Map<String, String> _getDefaultEnglishTranslations() {
    return {
      // App General
      'app_title': 'MenuMind',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'settings': 'Settings',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',

      // Home Screen
      'welcome_title': 'Welcome to MenuMind',
      'welcome_subtitle': 'Translate menus and discover cultural insights',
      'scan_menu': 'Scan Menu',
      'recent_scans': 'Recent Scans',
      'no_recent_scans': 'No recent scans yet',
      'view_all': 'View All',
      'features_title': 'Features',
      'feature_translate': 'Translate',
      'feature_translate_desc': 'Instant translation',
      'feature_allergens': 'Allergens',
      'feature_allergens_desc': 'Safety alerts',
      'feature_cultural': 'Cultural',
      'feature_cultural_desc': 'Local insights',
      'feature_ingredients': 'Smart Ingredients',
      'feature_ingredients_desc': 'Ingredient prediction',

      // Camera Screen
      'camera_title': 'Scan Menu',
      'camera_instructions': 'Point your camera at the menu and tap to capture',
      'capture_button': 'Capture',
      'switch_camera': 'Switch Camera',
      'flash': 'Flash',
      'retake': 'Retake',
      'use_photo': 'Use Photo',

      // Image Picker
      'select_image_source': 'Select Image Source',
      'take_photo': 'Take Photo',
      'take_photo_desc': 'Use your camera to capture the menu',
      'choose_from_gallery': 'Choose from Gallery',
      'choose_from_gallery_desc': 'Select an existing photo from your gallery',

      // Results Screen
      'menu_analysis': 'Menu Analysis',
      'analyzing_menu': 'Analyzing Menu',
      'analyzing_progress': 'Please wait while we analyze your menu image...',
      'processing_steps': 'Processing Steps',
      'step_image_processing': 'Processing Image',
      'step_text_extraction': 'Extracting Text',
      'step_translation': 'Translating Content',
      'step_cultural_analysis': 'Cultural Analysis',
      'analysis_complete': 'Analysis Complete',
      'found_dishes': 'Found dishes',
      'scan_another': 'Scan Another Menu',
      'allergen_warning': 'Allergen Warning',
      'try_again': 'Try Again',
      'go_back': 'Go Back',
      'results_saved_successfully': 'Results saved successfully!',
      'translation_complete': 'Translation Complete',
      'cultural_insights': 'Cultural Insights',
      'allergen_warnings': 'Allergen Warnings',
      'dish_ingredients': 'Ingredients',
      'dish_description': 'Description',
      'safe_for_you': 'Safe for you',
      'contains_allergens': 'Contains allergens',
      'view_details': 'View Details',

      // Settings Screen
      'language_settings': 'Language Settings',
      'preferred_language': 'Preferred Language',
      'theme_settings': 'Theme Settings',
      'dark_mode': 'Dark Mode',
      'allergen_settings': 'Allergen Settings',
      'my_allergies': 'My Allergies',
      'add_allergy': 'Add Allergy',
      'remove_allergy': 'Remove',
      'audio_settings': 'Audio Settings',
      'enable_sound': 'Enable Sound',
      'enable_vibration': 'Enable Vibration',

      // Common Food Terms
      'vegetarian': 'Vegetarian',
      'vegan': 'Vegan',
      'gluten_free': 'Gluten Free',
      'dairy_free': 'Dairy Free',
      'spicy': 'Spicy',
      'mild': 'Mild',
      'hot': 'Hot',
      'contains_nuts': 'Contains Nuts',
      'seafood': 'Seafood',
      'meat': 'Meat',
      'chicken': 'Chicken',
      'beef': 'Beef',
      'pork': 'Pork',
      'fish': 'Fish',

      // Allergens
      'milk': 'Milk',
      'eggs': 'Eggs',
      'peanuts': 'Peanuts',
      'tree_nuts': 'Tree Nuts',
      'soy': 'Soy',
      'wheat': 'Wheat',
      'shellfish': 'Shellfish',
      'sesame': 'Sesame',

      // Error Messages
      'camera_permission_denied': 'Camera permission denied',
      'camera_not_available': 'Camera not available',
      'analysis_failed': 'Menu analysis failed',
      'network_error': 'Network error',
      'translation_failed': 'Translation failed',
      'please_try_again': 'Please try again',
    };
  }

  Future<void> clearCache() async {
    try {
      await _localStorageDataSource.clearLanguagePacks();
      final englishPack = _createDefaultEnglishPack();
      emit(
        TranslationLoaded(
          languagePacks: {'en': englishPack},
          currentLanguage: 'en',
        ),
      );
    } catch (e) {
      emit(TranslationError(e.toString()));
    }
  }
}
