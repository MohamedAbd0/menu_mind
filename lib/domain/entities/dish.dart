import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  final String originalName;
  final String translatedName;
  final String culturalDescription;
  final List<String> ingredients;
  final List<String> dietaryTags;
  final List<String> detectedAllergens;
  final String language;
  final double confidence;

  const Dish({
    required this.originalName,
    required this.translatedName,
    required this.culturalDescription,
    required this.ingredients,
    required this.dietaryTags,
    required this.detectedAllergens,
    required this.language,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
    originalName,
    translatedName,
    culturalDescription,
    ingredients,
    dietaryTags,
    detectedAllergens,
    language,
    confidence,
  ];

  Dish copyWith({
    String? originalName,
    String? translatedName,
    String? culturalDescription,
    List<String>? ingredients,
    List<String>? dietaryTags,
    List<String>? detectedAllergens,
    String? language,
    double? confidence,
  }) {
    return Dish(
      originalName: originalName ?? this.originalName,
      translatedName: translatedName ?? this.translatedName,
      culturalDescription: culturalDescription ?? this.culturalDescription,
      ingredients: ingredients ?? this.ingredients,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      detectedAllergens: detectedAllergens ?? this.detectedAllergens,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalName': originalName,
      'translatedName': translatedName,
      'culturalDescription': culturalDescription,
      'ingredients': ingredients,
      'dietaryTags': dietaryTags,
      'detectedAllergens': detectedAllergens,
      'language': language,
      'confidence': confidence,
    };
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      originalName: json['originalName'] ?? '',
      translatedName: json['translatedName'] ?? '',
      culturalDescription: json['culturalDescription'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      detectedAllergens: List<String>.from(json['detectedAllergens'] ?? []),
      language: json['language'] ?? 'en',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}
