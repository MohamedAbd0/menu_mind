import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/language_pack.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/gemma_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../datasources/gemma_datasource.dart';

@Injectable(as: GemmaRepository)
class GemmaRepositoryImpl implements GemmaRepository {
  final LocalStorageDataSource _localDataSource;
  final GemmaDataSource _gemmaDataSource;

  GemmaRepositoryImpl({
    required LocalStorageDataSource localDataSource,
    required GemmaDataSource gemmaDataSource,
  })  : _localDataSource = localDataSource,
        _gemmaDataSource = gemmaDataSource;

  @override
  Future<List<Dish>> analyzeMenuImage(
    Uint8List imageBytes,
    String targetLanguage,
    List<String> userAllergies,
  ) async {
    try {
      // Use the real AI model to parse the menu
      final menuData = await _gemmaDataSource.parseMenuFromImage(
        imageBytes,
        targetLanguage,
        userAllergies,
      );

      final dishes = <Dish>[];
      final dishesData = menuData['dishes'] as List<dynamic>? ?? [];

      for (final dishData in dishesData) {
        final dishMap = dishData as Map<String, dynamic>;

        // Extract basic dish information
        final originalName =
            dishMap['originalName'] as String? ?? 'Unknown Dish';
        final translatedName =
            dishMap['translatedName'] as String? ?? originalName;
        final culturalDescription = dishMap['culturalDescription'] as String? ??
            'No description available';
        final ingredients =
            List<String>.from(dishMap['ingredients'] as List? ?? []);
        final confidence = (dishMap['confidence'] as num?)?.toDouble() ?? 0.7;

        // Use dietary tags from AI response or generate fallback
        final dietaryTags =
            List<String>.from(dishMap['dietaryTags'] as List? ?? []);
        final fallbackDietaryTags = dietaryTags.isEmpty
            ? _getFallbackDietaryTags(originalName, ingredients)
            : dietaryTags;

        // Detect allergens using fast local method
        final detectedAllergens = _detectAllergensFromIngredients(
          ingredients,
          userAllergies,
        );

        final dish = Dish(
          originalName: originalName,
          translatedName: translatedName,
          culturalDescription: culturalDescription,
          ingredients: ingredients,
          dietaryTags: fallbackDietaryTags,
          detectedAllergens: detectedAllergens,
          language: targetLanguage,
          confidence: confidence,
        );

        dishes.add(dish);
      }

      // Sort by confidence (highest first)
      dishes.sort((a, b) => b.confidence.compareTo(a.confidence));

      return dishes;
    } catch (e) {
      throw Exception('Failed to analyze menu image: $e');
    }
  }

  @override
  Future<Map<String, String>> translateUIStrings(
    Map<String, String> englishStrings,
    String targetLanguage,
  ) async {
    try {
      return await _gemmaDataSource.translateUIStrings(
        englishStrings,
        targetLanguage,
      );
    } catch (e) {
      // Fallback to basic translations if AI fails
      return _getFallbackTranslations(englishStrings, targetLanguage);
    }
  }

  @override
  Future<String> getCulturalDescription(
    String dishName,
    String targetLanguage,
  ) async {
    try {
      return await _gemmaDataSource.getCulturalDescription(
        dishName,
        targetLanguage,
      );
    } catch (e) {
      return _getFallbackCulturalDescription(dishName, targetLanguage);
    }
  }

  @override
  Future<List<String>> predictIngredients(
    String dishName,
    String originalLanguage,
  ) async {
    try {
      return await _gemmaDataSource.predictIngredients(
        dishName,
        originalLanguage,
      );
    } catch (e) {
      return ['Unknown ingredients'];
    }
  }

  @override
  Future<List<String>> detectDietaryTags(
    String dishName,
    List<String> ingredients,
  ) async {
    try {
      return await _gemmaDataSource.detectDietaryTags(
        dishName,
        ingredients,
      );
    } catch (e) {
      return _getFallbackDietaryTags(dishName, ingredients);
    }
  }

  @override
  Future<List<String>> detectAllergens(
    List<String> ingredients,
    List<String> userAllergies,
  ) async {
    try {
      return await _gemmaDataSource.detectAllergens(
        ingredients,
        userAllergies,
      );
    } catch (e) {
      return _detectAllergensFromIngredients(ingredients, userAllergies);
    }
  }

  @override
  Future<void> initializeModel() async {
    try {
      await _gemmaDataSource.initialize();
    } catch (e) {
      throw Exception('Failed to initialize AI model: $e');
    }
  }

  @override
  bool get isModelInitialized => _gemmaDataSource.isInitialized;

  @override
  Future<List<LanguagePack>> getAvailableLanguagePacks() async {
    return await _localDataSource.getAllLanguagePacks();
  }

  @override
  Future<void> saveLanguagePack(LanguagePack languagePack) async {
    await _localDataSource.saveLanguagePack(languagePack);
  }

  @override
  Future<LanguagePack?> loadLanguagePack(String languageCode) async {
    return await _localDataSource.getLanguagePack(languageCode);
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _localDataSource.saveUserPreferences(preferences);
  }

  @override
  Future<UserPreferences> loadUserPreferences() async {
    return await _localDataSource.getUserPreferences();
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearAllData();
  }

  // Helper methods
  String _getCulturalDescription(String dishName, String targetLanguage) {
    if (targetLanguage == 'ar') {
      final descriptions = {
        'Pasta Carbonara':
            'طبق إيطالي تقليدي من روما، يُحضر بالبيض والجبن ولحم الخنزير المقدد. يُعتبر من الأطباق الكلاسيكية في المطبخ الإيطالي.',
        'Margherita Pizza':
            'بيتزا إيطالية كلاسيكية سُميت على اسم الملكة مارغريتا. تُحضر بالطماطم والموزاريلا والريحان لتمثيل ألوان العلم الإيطالي.',
        'Spaghetti Carbonara':
            'طبق إيطالي تقليدي من روما، يُحضر بالبيض والجبن ولحم الخنزير المقدد. يُعتبر من الأطباق الكلاسيكية في المطبخ الإيطالي.',
        'Chicken Tikka Masala':
            'طبق هندي شهير يتكون من قطع الدجاج المتبلة والمطبوخة في صلصة الطماطم الكريمية. يُعتبر من أشهر الأطباق في المطابخ الهندية والبريطانية.',
        'Pad Thai':
            'طبق تايلندي تقليدي من النودلز المقلية مع الروبيان أو التوفو والخضروات. يُعتبر من أشهر الأطباق التايلندية عالمياً.',
        'Beef Bourguignon':
            'طبق فرنسي تقليدي من لحم البقر المطبوخ ببطء في النبيذ الأحمر مع الخضروات. نشأ في منطقة بورغندي بفرنسا.',
        'Sushi Combo':
            'مجموعة متنوعة من السوشي الياباني التقليدي، يُحضر بالأرز المتبل والأسماك الطازجة. يعكس فن الطبخ الياباني وتقديره للمكونات الطازجة.',
        'Caesar Salad':
            'سلطة أمريكية كلاسيكية ابتكرها الطاهي قيصر كارديني في المكسيك. تتكون من الخس الروماني والجبن والخبز المحمص.',
        'Paella Valenciana':
            'طبق إسباني تقليدي من منطقة فالنسيا، يُحضر بالأرز والزعفران واللحوم والخضروات. يُعتبر رمزاً للمطبخ الإسباني.',
        'Fish and Chips':
            'طبق بريطاني تقليدي يتكون من السمك المقلي والبطاطس المقلية. نشأ في القرن التاسع عشر وأصبح رمزاً للمطبخ البريطاني.',
      };
      return descriptions[dishName] ?? 'وصف ثقافي غير متوفر';
    } else if (targetLanguage == 'es') {
      final descriptions = {
        'Pasta Carbonara':
            'Plato tradicional italiano de Roma, preparado con huevos, queso y tocino. Se considera uno de los platos clásicos de la cocina italiana.',
        'Margherita Pizza':
            'Pizza italiana clásica nombrada en honor a la Reina Margarita. Se prepara con tomate, mozzarella y albahaca para representar los colores de la bandera italiana.',
        'Spaghetti Carbonara':
            'Plato tradicional italiano de Roma, preparado con huevos, queso y pancetta. Se considera uno de los platos clásicos de la cocina italiana.',
        'Chicken Tikka Masala':
            'Plato indio popular que consiste en pollo especiado cocinado en una salsa cremosa de tomate. Es uno de los platos más famosos de la cocina india y británica.',
        'Pad Thai':
            'Plato tailandés tradicional de fideos salteados con camarones o tofu y vegetales. Es uno de los platos tailandeses más famosos mundialmente.',
        'Beef Bourguignon':
            'Plato francés tradicional de carne de res cocida lentamente en vino tinto con vegetales. Originario de la región de Borgoña en Francia.',
        'Sushi Combo':
            'Variedad de sushi japonés tradicional, preparado con arroz sazonado y pescado fresco. Refleja el arte culinario japonés y su aprecio por ingredientes frescos.',
        'Caesar Salad':
            'Ensalada americana clásica creada por el chef César Cardini en México. Consiste en lechuga romana con queso parmesano y croutones.',
        'Paella Valenciana':
            'Plato español tradicional de la región de Valencia, preparado con arroz, azafrán, carnes y vegetales. Se considera un símbolo de la cocina española.',
        'Fish and Chips':
            'Plato británico tradicional que consiste en pescado rebozado y papas fritas. Originario del siglo XIX y se convirtió en símbolo de la cocina británica.',
      };
      return descriptions[dishName] ?? 'Descripción cultural no disponible';
    }

    final descriptions = {
      'Pasta Carbonara':
          'A traditional Italian dish from Rome, made with eggs, cheese, and bacon. It\'s considered one of the classic dishes in Italian cuisine.',
      'Margherita Pizza':
          'A classic Italian pizza named after Queen Margherita. It\'s made with tomatoes, mozzarella, and basil to represent the colors of the Italian flag.',
      'Spaghetti Carbonara':
          'A traditional Italian dish from Rome, made with eggs, cheese, and pancetta. It\'s considered one of the classic dishes in Italian cuisine.',
      'Chicken Tikka Masala':
          'A popular Indian dish consisting of spiced chicken cooked in a creamy tomato sauce. It\'s one of the most famous dishes in Indian and British cuisine.',
      'Pad Thai':
          'A traditional Thai dish of stir-fried noodles with shrimp or tofu and vegetables. It\'s one of the most famous Thai dishes worldwide.',
      'Beef Bourguignon':
          'A traditional French dish of beef slowly cooked in red wine with vegetables. It originated in the Burgundy region of France.',
      'Sushi Combo':
          'A variety of traditional Japanese sushi, prepared with seasoned rice and fresh fish. It reflects Japanese culinary art and appreciation for fresh ingredients.',
      'Caesar Salad':
          'A classic American salad created by chef Caesar Cardini in Mexico. It consists of romaine lettuce with parmesan cheese and croutons.',
      'Paella Valenciana':
          'A traditional Spanish dish from the Valencia region, prepared with rice, saffron, meats, and vegetables. It\'s considered a symbol of Spanish cuisine.',
      'Fish and Chips':
          'A traditional British dish consisting of battered fish and fried potatoes. It originated in the 19th century and became a symbol of British cuisine.',
    };
    return descriptions[dishName] ?? 'Cultural description not available';
  }

  List<String> _detectAllergensFromIngredients(
    List<String> ingredients,
    List<String> userAllergies,
  ) {
    final detectedAllergens = <String>[];

    for (final allergy in userAllergies) {
      final allergyLower = allergy.toLowerCase();
      for (final ingredient in ingredients) {
        final ingredientLower = ingredient.toLowerCase();

        if ((allergyLower == 'dairy' &&
                [
                  'cheese',
                  'milk',
                  'cream',
                  'butter',
                ].any((d) => ingredientLower.contains(d))) ||
            (allergyLower == 'eggs' && ingredientLower.contains('egg')) ||
            (allergyLower == 'gluten' &&
                [
                  'pasta',
                  'dough',
                  'bread',
                ].any((g) => ingredientLower.contains(g))) ||
            (allergyLower == 'nuts' &&
                [
                  'nuts',
                  'almond',
                  'peanut',
                ].any((n) => ingredientLower.contains(n))) ||
            (allergyLower == 'shellfish' &&
                [
                  'shrimp',
                  'crab',
                  'lobster',
                ].any((s) => ingredientLower.contains(s))) ||
            (allergyLower == 'fish' && ingredientLower.contains('fish')) ||
            (allergyLower == 'soy' && ingredientLower.contains('soy'))) {
          if (!detectedAllergens.contains(allergy)) {
            detectedAllergens.add(allergy);
          }
        }
      }
    }

    return detectedAllergens;
  }

  // Fallback methods for when AI fails
  Map<String, String> _getFallbackTranslations(
    Map<String, String> englishStrings,
    String targetLanguage,
  ) {
    if (targetLanguage == 'ar') {
      return {
        'scan_menu': 'امسح القائمة',
        'settings': 'الإعدادات',
        'no_dishes_found': 'لم يتم العثور على أطباق',
        'listen': 'استمع',
        'vegetarian': 'نباتي',
        'halal': 'حلال',
        'spicy': 'حار',
        'ingredients': 'المكونات',
        'cultural_insight': 'نظرة ثقافية',
        'allergy_warning': 'تحذير من الحساسية',
        ...englishStrings,
      };
    } else if (targetLanguage == 'es') {
      return {
        'scan_menu': 'Escanear Menú',
        'settings': 'Configuración',
        'no_dishes_found': 'No se encontraron platos',
        'listen': 'Escuchar',
        'vegetarian': 'Vegetariano',
        'halal': 'Halal',
        'spicy': 'Picante',
        'ingredients': 'Ingredientes',
        'cultural_insight': 'Perspectiva Cultural',
        'allergy_warning': 'Advertencia de Alergia',
        ...englishStrings,
      };
    }
    return englishStrings;
  }

  String _getFallbackCulturalDescription(
      String dishName, String targetLanguage) {
    return _getCulturalDescription(dishName, targetLanguage);
  }

  List<String> _getFallbackDietaryTags(
      String dishName, List<String> ingredients) {
    final tags = <String>[];
    final lowerIngredients = ingredients.map((i) => i.toLowerCase()).toSet();

    if (!lowerIngredients.any(
      (i) => ['meat', 'chicken', 'beef', 'pork', 'fish'].contains(i),
    )) {
      tags.add('Vegetarian');
    }

    if (lowerIngredients.any(
      (i) => ['spices', 'pepper', 'chili'].contains(i),
    )) {
      tags.add('Spicy');
    }

    if (lowerIngredients.any(
      (i) => ['fish', 'shrimp', 'crab', 'lobster'].contains(i),
    )) {
      tags.add('Seafood');
    }

    if (lowerIngredients.any(
      (i) => ['cheese', 'cream', 'milk', 'butter'].contains(i),
    )) {
      tags.add('Contains Dairy');
    }

    return tags;
  }
}
