import '../../domain/entities/dish.dart';

// part 'dish_model.g.dart';
// TODO: Enable when build_runner is set up properly

// @HiveType(typeId: 0)
class DishModel {
  // @HiveField(0)
  final String originalName;

  // @HiveField(1)
  final String translatedName;

  // @HiveField(2)
  final String description;

  // @HiveField(3)
  final String translatedDescription;

  // @HiveField(4)
  final List<String> ingredients;

  // @HiveField(5)
  final List<String> allergens;

  // @HiveField(6)
  final double? price;

  // @HiveField(7)
  final String? currency;

  // @HiveField(8)
  final String? category;

  // @HiveField(9)
  final bool isSpicy;

  // @HiveField(10)
  final bool isVegetarian;

  // @HiveField(11)
  final bool isVegan;

  // @HiveField(12)
  final bool isGlutenFree;

  // @HiveField(13)
  final String culturalDescription;

  // @HiveField(14)
  final List<String> dietaryTags;

  // @HiveField(15)
  final List<String> detectedAllergens;

  // @HiveField(16)
  final String language;

  // @HiveField(17)
  final double confidence;

  DishModel({
    required this.originalName,
    required this.translatedName,
    required this.description,
    required this.translatedDescription,
    required this.ingredients,
    required this.allergens,
    this.price,
    this.currency,
    this.category,
    required this.isSpicy,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.culturalDescription,
    required this.dietaryTags,
    required this.detectedAllergens,
    required this.language,
    required this.confidence,
  });

  factory DishModel.fromEntity(Dish dish) {
    return DishModel(
      originalName: dish.originalName,
      translatedName: dish.translatedName,
      description: '', // TODO: Add description field to Dish entity
      translatedDescription:
          '', // TODO: Add translatedDescription field to Dish entity
      culturalDescription: dish.culturalDescription,
      ingredients: dish.ingredients,
      allergens: dish.detectedAllergens, // Map detectedAllergens to allergens
      price: null, // TODO: Add price field to Dish entity if needed
      currency: null, // TODO: Add currency field to Dish entity if needed
      category: null, // TODO: Add category field to Dish entity if needed
      isSpicy: dish.dietaryTags.contains('Spicy'),
      isVegetarian: dish.dietaryTags.contains('Vegetarian'),
      isVegan: dish.dietaryTags.contains('Vegan'),
      isGlutenFree: dish.dietaryTags.contains('Gluten Free'),
      dietaryTags: dish.dietaryTags,
      detectedAllergens: dish.detectedAllergens,
      language: dish.language,
      confidence: dish.confidence,
    );
  }

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      originalName: json['originalName'] ?? '',
      translatedName: json['translatedName'] ?? '',
      description: json['description'] ?? '',
      translatedDescription: json['translatedDescription'] ?? '',
      culturalDescription: json['culturalDescription'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      price: json['price']?.toDouble(),
      currency: json['currency'],
      category: json['category'],
      isSpicy: json['isSpicy'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      detectedAllergens: List<String>.from(json['detectedAllergens'] ?? []),
      language: json['language'] ?? 'en',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Dish toEntity() {
    return Dish(
      originalName: originalName,
      translatedName: translatedName,
      culturalDescription: culturalDescription,
      ingredients: ingredients,
      dietaryTags: dietaryTags,
      detectedAllergens: detectedAllergens,
      language: language,
      confidence: confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalName': originalName,
      'translatedName': translatedName,
      'description': description,
      'translatedDescription': translatedDescription,
      'culturalDescription': culturalDescription,
      'ingredients': ingredients,
      'allergens': allergens,
      'price': price,
      'currency': currency,
      'category': category,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'dietaryTags': dietaryTags,
      'detectedAllergens': detectedAllergens,
      'language': language,
      'confidence': confidence,
    };
  }
}
