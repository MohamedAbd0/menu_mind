import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:injectable/injectable.dart';
import 'gemma_downloader_datasource.dart';

@injectable
class GemmaDataSource {
  InferenceModel? _inferenceModel;
  bool _isInitialized = false;
  late final GemmaDownloaderDataSource _downloaderDataSource;

  // Your Hugging Face token
  static const String _accessToken = "YOUR_HUGGING_FACE_TOKEN";

  GemmaDataSource() {
    _downloaderDataSource = GemmaDownloaderDataSource(
      model: DownloadModel(
        modelUrl:
            'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task',
        modelFilename: 'gemma-3n-E4B-it-int4.task',
      ),
      accessToken: _accessToken,
    );
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    Function(String)? onStatusUpdate,
    Function(double?)? onProgress,
  }) async {
    if (_isInitialized) return;

    try {
      onStatusUpdate?.call('Checking model availability...');

      // Check if model exists locally
      final isModelInstalled =
          await _downloaderDataSource.checkModelExistence();

      if (!isModelInstalled) {
        onStatusUpdate?.call('Downloading Gemma 3N model...');

        await _downloaderDataSource.downloadModel(
          onProgress: (progress) {
            onProgress?.call(progress);
          },
        );
      }

      onStatusUpdate?.call('Initializing model...');
      onProgress?.call(null); // Clear progress indicator

      // Set the model path for flutter_gemma
      final modelPath = await _downloaderDataSource.getFilePath();
      await FlutterGemmaPlugin.instance.modelManager.setModelPath(modelPath);

      final gemma = FlutterGemmaPlugin.instance;
      _inferenceModel = await gemma.createModel(
        modelType: ModelType.gemmaIt,
        supportImage: true,
        maxTokens: 2048, // Increased to handle longer prompts
      );

      _isInitialized = true;
      onStatusUpdate?.call('Model ready!');
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize Gemma model: $e');
    }
  }

  Future<String> generateTextResponse(String prompt) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Validate prompt length to prevent token limit issues
    const maxPromptLength = 1500; // Conservative limit
    if (prompt.length > maxPromptLength) {
      debugPrint('⚠️ Prompt too long (${prompt.length} chars), truncating...');
      prompt = prompt.substring(0, maxPromptLength) + '...';
    }

    try {
      // Use session for single text-only inference with optimized settings
      final session = await _inferenceModel!.createSession(
        temperature:
            0.1, // Lower temperature for faster, more focused responses
        randomSeed: 1,
        topK: 1, // More focused responses
      );

      await session.addQueryChunk(Message.text(text: prompt, isUser: true));

      // Add timeout to prevent hanging
      final response = await session.getResponse().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⚠️ Translation timeout after 30 seconds');
          throw Exception('Translation timeout - response took too long');
        },
      );

      await session.close();

      return response;
    } catch (e) {
      debugPrint('❌ Failed to generate text response: $e');
      throw Exception('Failed to generate text response: $e');
    }
  }

  Future<String> analyzeImageWithText(
    Uint8List imageBytes,
    String prompt,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Use session for single multimodal inference with optimized settings
      final session = await _inferenceModel!.createSession(
        enableVisionModality: true,
        temperature: 0.5, // Lower temperature for more consistent output
        randomSeed: 1,
        topK: 1, // Slightly higher for better quality
      );

      await session.addQueryChunk(
        Message.withImage(text: prompt, imageBytes: imageBytes, isUser: true),
      );

      final response = await session.getResponse();
      await session.close();

      return response;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  Future<Map<String, dynamic>> parseMenuFromImage(
    Uint8List imageBytes,
    String targetLanguage,
    List<String> userAllergies,
  ) async {
    final prompt = '''
Extract menu items as JSON:
{
  "dishes": [
    {
      "originalName": "dish name",
      "translatedName": "name in $targetLanguage", 
      "culturalDescription": "brief info",
      "ingredients": ["ingredient1", "ingredient2"],
      "dietaryTags": ["vegetarian", "spicy"],
      "confidence": 0.9
    }
  ]
}

Target: $targetLanguage
Allergies: ${userAllergies.take(3).join(', ')}
Return only JSON.''';

    final response = await analyzeImageWithText(imageBytes, prompt);

    try {
      // Try to extract JSON from potential markdown code blocks
      final cleanedResponse = _extractJsonFromResponse(response);
      return json.decode(cleanedResponse);
    } catch (e) {
      debugPrint('JSON parsing failed: $e');
      debugPrint('Response was: $response');
      // Try to fix the JSON if it's incomplete
      final cleanedResponse = _extractJsonFromResponse(response);
      final fixedJson = _attemptJsonFix(cleanedResponse);
      if (fixedJson != null) {
        try {
          return json.decode(fixedJson);
        } catch (e2) {
          debugPrint('Fixed JSON also failed: $e2');
        }
      }
      // If all parsing fails, use fallback
      return _fallbackMenuParsing(response, targetLanguage);
    }
  }

  Future<Map<String, String>> translateUIStrings(
    Map<String, String> englishStrings,
    String targetLanguage,
  ) async {
    // Limit the number of strings to translate at once to avoid token limit
    const maxStringsPerBatch = 10;
    final entries = englishStrings.entries.take(maxStringsPerBatch).toList();

    final prompt = '''
Translate to $targetLanguage:

${entries.map((e) => '"${e.key}": "${e.value}"').join('\n')}

Return JSON:
{
  "key1": "translated_value1",
  "key2": "translated_value2"
}''';

    debugPrint('🚀 Starting translation to $targetLanguage...');

    try {
      // Add overall timeout for the entire translation process
      final response = await generateTextResponse(prompt).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          debugPrint('⚠️ Translation process timeout after 45 seconds');
          throw Exception('Translation timeout');
        },
      );

      debugPrint('✅ Got response, parsing JSON...');

      final cleanedResponse = _extractJsonFromResponse(response);
      final decoded = json.decode(cleanedResponse);

      // If we processed only a subset, merge with remaining strings
      final result = Map<String, String>.from(decoded);
      if (englishStrings.length > maxStringsPerBatch) {
        final remaining = Map<String, String>.fromEntries(
          englishStrings.entries.skip(maxStringsPerBatch),
        );
        // Add remaining strings as fallback translations
        result.addAll(_getFallbackTranslations(remaining, targetLanguage));
      }

      debugPrint(
        '✅ Successfully translated UI strings to $targetLanguage using Gemma AI',
      );
      return result;
    } catch (e) {
      debugPrint('❌ UI translation failed for $targetLanguage: $e');
      debugPrint('Falling back to original strings...');

      // If translation fails or times out, return basic translations
      return _getFallbackTranslations(englishStrings, targetLanguage);
    }
  }

  /// Provides basic fallback translations when AI translation fails
  Map<String, String> _getFallbackTranslations(
    Map<String, String> englishStrings,
    String targetLanguage,
  ) {
    // Basic translation mapping for common UI terms
    final commonTranslations = <String, Map<String, String>>{
      'es': {
        'settings': 'Configuración',
        'language': 'Idioma',
        'back': 'Atrás',
        'save': 'Guardar',
        'cancel': 'Cancelar',
        'loading': 'Cargando',
        'error': 'Error',
        'menu': 'Menú',
        'ingredients': 'Ingredientes',
        'allergies': 'Alergias',
      },
      'fr': {
        'settings': 'Paramètres',
        'language': 'Langue',
        'back': 'Retour',
        'save': 'Enregistrer',
        'cancel': 'Annuler',
        'loading': 'Chargement',
        'error': 'Erreur',
        'menu': 'Menu',
        'ingredients': 'Ingrédients',
        'allergies': 'Allergies',
      },
      'ar': {
        'settings': 'الإعدادات',
        'language': 'اللغة',
        'back': 'رجوع',
        'save': 'حفظ',
        'cancel': 'إلغاء',
        'loading': 'جاري التحميل',
        'error': 'خطأ',
        'menu': 'القائمة',
        'ingredients': 'المكونات',
        'allergies': 'الحساسية',
      },
    };

    final translations = <String, String>{};
    final langTranslations = commonTranslations[targetLanguage] ?? {};

    for (final entry in englishStrings.entries) {
      final key = entry.key;
      final value = entry.value;

      // Check if we have a basic translation for this key
      if (langTranslations.containsKey(key)) {
        translations[key] = langTranslations[key]!;
      } else {
        // Keep original if no translation available
        translations[key] = value;
      }
    }

    debugPrint('🔄 Using fallback translations for $targetLanguage');
    return translations;
  }

  Future<String> getCulturalDescription(
    String dishName,
    String targetLanguage,
  ) async {
    final prompt = '''
Describe "$dishName" in $targetLanguage:
- Origin and cultural significance
- Traditional preparation
- When it's eaten

Keep it brief (2-3 sentences).''';

    return await generateTextResponse(prompt);
  }

  Future<List<String>> predictIngredients(
    String dishName,
    String originalLanguage,
  ) async {
    final prompt = '''
List ingredients for "$dishName" ($originalLanguage):
- Main ingredients only
- Include common allergens
- One per line

Format:
- Ingredient 1
- Ingredient 2''';

    final response = await generateTextResponse(prompt);

    try {
      // Parse the response to extract ingredients
      return response
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            // Remove various bullet point formats
            if (line.startsWith('-')) {
              return line.substring(1).trim();
            } else if (line.startsWith('•')) {
              return line.substring(1).trim();
            } else if (line.startsWith('*')) {
              return line.substring(1).trim();
            } else if (RegExp(r'^\d+\.').hasMatch(line)) {
              return line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
            }
            return line.trim();
          })
          .where((ingredient) => ingredient.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Ingredient parsing failed: $e');
      return ['Unknown ingredients'];
    }
  }

  Future<List<String>> detectDietaryTags(
    String dishName,
    List<String> ingredients,
  ) async {
    final prompt = '''
Dietary tags for "$dishName" with ${ingredients.take(5).join(', ')}:

Tags: vegetarian, vegan, halal, kosher, spicy, seafood, gluten-free, dairy-free, nuts, soy

List applicable tags:''';

    final response = await generateTextResponse(prompt);

    try {
      return response
          .split('\n')
          .map((line) => line.trim())
          .where((tag) => tag.isNotEmpty)
          .map((tag) {
            // Clean up any formatting
            tag = tag.replaceAll(RegExp(r'^[-•*]\s*'), '');
            tag = tag.replaceAll(RegExp(r'^\d+\.\s*'), '');
            return tag.trim();
          })
          .where((tag) => tag.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Dietary tags parsing failed: $e');
      return [];
    }
  }

  Future<List<String>> detectAllergens(
    List<String> ingredients,
    List<String> userAllergies,
  ) async {
    final prompt = '''
Check ingredients: ${ingredients.take(5).join(', ')}
For allergens: ${userAllergies.take(5).join(', ')}

List detected allergens:''';

    final response = await generateTextResponse(prompt);

    try {
      return response
          .split('\n')
          .map((line) => line.trim())
          .map((line) {
            // Clean up any formatting
            line = line.replaceAll(RegExp(r'^[-•*]\s*'), '');
            line = line.replaceAll(RegExp(r'^\d+\.\s*'), '');
            return line.trim();
          })
          .where(
            (allergen) =>
                allergen.isNotEmpty && userAllergies.contains(allergen),
          )
          .toList();
    } catch (e) {
      debugPrint('Allergen detection parsing failed: $e');
      return [];
    }
  }

  Map<String, dynamic> _fallbackMenuParsing(
    String response,
    String targetLanguage,
  ) {
    // Try to extract useful information from the partial response
    List<Map<String, dynamic>> dishes = [];

    try {
      // Look for multiple dish patterns in the response
      final dishPatterns = [
        RegExp(
          r'"originalName":\s*"([^"]+)"[^}]*?"translatedName":\s*"([^"]*)"[^}]*?"culturalDescription":\s*"([^"]*)"',
        ),
        RegExp(r'"originalName":\s*"([^"]+)"'),
      ];

      final allMatches = <Match>[];
      for (final pattern in dishPatterns) {
        allMatches.addAll(pattern.allMatches(response));
      }

      // Sort matches by their position in the response
      allMatches.sort((a, b) => a.start.compareTo(b.start));

      // Process each match
      for (final match in allMatches) {
        if (match.groupCount >= 1) {
          final originalName = match.group(1) ?? "Menu Item";
          final translatedName = match.groupCount >= 2 && match.group(2) != null
              ? match.group(2)!
              : originalName;
          final culturalDescription =
              match.groupCount >= 3 && match.group(3) != null
                  ? match.group(3)! + "..."
                  : "Cultural description not available";

          // Look for ingredients near this dish
          final dishStart = match.start;
          final dishEnd = match.end;
          final contextRange = response.substring(
            dishStart,
            (dishEnd + 200).clamp(0, response.length),
          );

          List<String> ingredients = ["Unknown ingredients"];
          List<String> dietaryTags = [];
          double confidence = 0.5;

          // Extract ingredients from context
          final ingredientsPattern = RegExp(r'"ingredients":\s*\[([^\]]*)\]');
          final ingredientsMatch = ingredientsPattern.firstMatch(contextRange);
          if (ingredientsMatch != null) {
            final ingredientsList = ingredientsMatch.group(1) ?? "";
            final extractedIngredients = ingredientsList
                .split(',')
                .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                .where((e) => e.isNotEmpty)
                .toList();
            if (extractedIngredients.isNotEmpty) {
              ingredients = extractedIngredients;
            }
          }

          // Extract dietary tags from context
          final tagsPattern = RegExp(r'"dietaryTags":\s*\[([^\]]*)\]');
          final tagsMatch = tagsPattern.firstMatch(contextRange);
          if (tagsMatch != null) {
            final tagsList = tagsMatch.group(1) ?? "";
            dietaryTags = tagsList
                .split(',')
                .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                .where((e) => e.isNotEmpty)
                .toList();
          }

          // Extract confidence from context
          final confPattern = RegExp(r'"confidence":\s*([\d.]+)');
          final confMatch = confPattern.firstMatch(contextRange);
          if (confMatch != null) {
            confidence = double.tryParse(confMatch.group(1) ?? "0.5") ?? 0.5;
          }

          dishes.add({
            "originalName": originalName,
            "translatedName": translatedName,
            "culturalDescription": culturalDescription,
            "ingredients": ingredients,
            "dietaryTags": dietaryTags,
            "confidence": confidence,
          });
        }
      }

      // If no dishes found, create a default one
      if (dishes.isEmpty) {
        dishes.add({
          "originalName": "Menu Item",
          "translatedName": "Menu Item",
          "culturalDescription": "Unable to parse menu details",
          "ingredients": ["Unknown ingredients"],
          "dietaryTags": [],
          "confidence": 0.3,
        });
      }
    } catch (e) {
      debugPrint('Enhanced fallback parsing failed: $e');
      // Final fallback
      dishes = [
        {
          "originalName": "Menu Item",
          "translatedName": "Menu Item",
          "culturalDescription": "Parsing failed",
          "ingredients": ["Unknown ingredients"],
          "dietaryTags": [],
          "confidence": 0.2,
        },
      ];
    }

    return {"dishes": dishes};
  }

  String _extractJsonFromResponse(String response) {
    // Remove markdown code blocks if present
    String cleaned = response.trim();

    // Check for ```json code blocks
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7); // Remove ```json
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3); // Remove ```
    }

    // Remove closing code block
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    // Trim any remaining whitespace
    cleaned = cleaned.trim();

    // If the response doesn't look like JSON, try to find JSON within it
    if (!cleaned.startsWith('{') && !cleaned.startsWith('[')) {
      final jsonStartIndex = cleaned.indexOf('{');
      final jsonEndIndex = cleaned.lastIndexOf('}');

      if (jsonStartIndex != -1 &&
          jsonEndIndex != -1 &&
          jsonEndIndex > jsonStartIndex) {
        cleaned = cleaned.substring(jsonStartIndex, jsonEndIndex + 1);
      }
    }

    return cleaned;
  }

  String? _attemptJsonFix(String incompleteJson) {
    try {
      // If the JSON is incomplete, try to fix common issues
      String fixed = incompleteJson.trim();

      // Handle incomplete strings - more sophisticated detection
      final quoteCount = '"'.allMatches(fixed).length;
      if (quoteCount % 2 == 1) {
        // Odd number of quotes means there's an unclosed string
        // Find the last quote and see if it's part of an incomplete value
        final lastQuoteIndex = fixed.lastIndexOf('"');
        if (lastQuoteIndex != -1) {
          final beforeQuote = fixed.substring(0, lastQuoteIndex);

          // Check if this looks like an incomplete string value
          if (beforeQuote.endsWith(': ') || beforeQuote.endsWith(':"')) {
            // This is likely an incomplete value, try to salvage what we can
            // Remove the incomplete entry entirely
            final colonIndex = beforeQuote.lastIndexOf(':');
            if (colonIndex != -1) {
              // Find the start of this key-value pair
              final keyStartIndex = beforeQuote.lastIndexOf(
                '"',
                colonIndex - 1,
              );
              if (keyStartIndex != -1) {
                final keyKeyStartIndex = beforeQuote.lastIndexOf(
                  '"',
                  keyStartIndex - 1,
                );
                if (keyKeyStartIndex != -1) {
                  // Remove the entire incomplete key-value pair
                  fixed = beforeQuote.substring(0, keyKeyStartIndex);
                  // Remove trailing comma if present
                  fixed = fixed.replaceAll(RegExp(r',\s*$'), '');
                }
              }
            }
          } else {
            // Just close the string
            fixed = fixed + '"';
          }
        }
      }

      // Handle incomplete arrays
      final openBrackets = fixed.split('[').length - 1;
      final closeBrackets = fixed.split(']').length - 1;
      for (int i = 0; i < openBrackets - closeBrackets; i++) {
        fixed += ']';
      }

      // Handle incomplete objects
      final openBraces = fixed.split('{').length - 1;
      final closeBraces = fixed.split('}').length - 1;
      for (int i = 0; i < openBraces - closeBraces; i++) {
        fixed += '}';
      }

      // Remove trailing commas that might break JSON
      fixed = fixed.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

      // Final cleanup - remove any incomplete trailing entries
      fixed = fixed.replaceAll(RegExp(r',\s*$'), '');

      return fixed;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _inferenceModel?.close();
    _inferenceModel = null;
    _isInitialized = false;
  }
}
