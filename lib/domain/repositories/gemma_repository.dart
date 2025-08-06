import 'dart:typed_data';
import '../entities/dish.dart';
import '../entities/language_pack.dart';
import '../entities/user_preferences.dart';

abstract class GemmaRepository {
  /// Analyze menu image and extract dishes with translations and cultural insights
  Future<List<Dish>> analyzeMenuImage(
    Uint8List imageBytes,
    String targetLanguage,
    List<String> userAllergies,
  );

  /// Translate UI strings to target language
  Future<Map<String, String>> translateUIStrings(
    Map<String, String> englishStrings,
    String targetLanguage,
  );

  /// Get cultural description for a specific dish
  Future<String> getCulturalDescription(String dishName, String targetLanguage);

  /// Predict ingredients for a dish
  Future<List<String>> predictIngredients(
    String dishName,
    String originalLanguage,
  );

  /// Detect dietary information for a dish
  Future<List<String>> detectDietaryTags(
    String dishName,
    List<String> ingredients,
  );

  /// Check for allergens in ingredients
  Future<List<String>> detectAllergens(
    List<String> ingredients,
    List<String> userAllergies,
  );

  /// Initialize Gemma model
  Future<void> initializeModel();

  /// Check if model is initialized
  bool get isModelInitialized;

  /// Get available language packs
  Future<List<LanguagePack>> getAvailableLanguagePacks();

  /// Save language pack locally
  Future<void> saveLanguagePack(LanguagePack languagePack);

  /// Load language pack from local storage
  Future<LanguagePack?> loadLanguagePack(String languageCode);

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences);

  /// Load user preferences
  Future<UserPreferences> loadUserPreferences();

  /// Clear all cached data
  Future<void> clearCache();
}
