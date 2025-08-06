import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/dietary_chip.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/user_preferences_cubit.dart';
import '../cubits/translation_cubit.dart';
import '../../domain/entities/dish.dart';

class MenuAnalysisScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const MenuAnalysisScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<MenuAnalysisScreen> createState() => _MenuAnalysisScreenState();
}

class _MenuAnalysisScreenState extends State<MenuAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    final menuCubit = context.read<MenuCubit>();
    final preferencesCubit = context.read<UserPreferencesCubit>();
    final translationCubit = context.read<TranslationCubit>();

    // Get user preferences
    String targetLanguage = 'English';
    List<String> userAllergies = [];

    if (preferencesCubit.state is UserPreferencesLoaded) {
      final preferences =
          (preferencesCubit.state as UserPreferencesLoaded).preferences;
      targetLanguage = preferences.preferredLanguage;
      userAllergies = preferences.allergies;
    }

    if (translationCubit.state is TranslationLoaded) {
      targetLanguage =
          (translationCubit.state as TranslationLoaded).currentLanguage;
    }

    // Start menu analysis
    menuCubit.analyzeMenu(
      imageBytes: widget.imageBytes,
      targetLanguage: targetLanguage,
      userAllergies: userAllergies,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, translationState) {
        String translate(String key) {
          if (translationState is TranslationLoaded) {
            final pack = translationState
                .languagePacks[translationState.currentLanguage];
            return pack?.translations[key] ?? key;
          }
          return key;
        }

        final theme = Theme.of(context);
        final isRTL = translationState is TranslationLoaded &&
            TranslationCubit.rtlLanguages
                .contains(translationState.currentLanguage);

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              title: Text(
                translate('menu_analysis'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: BlocBuilder<MenuCubit, MenuState>(
              builder: (context, menuState) {
                if (menuState is MenuLoading) {
                  return _buildLoadingView(
                      context, translate, theme, menuState.progress);
                } else if (menuState is MenuAnalysisSuccess) {
                  return _buildSuccessView(
                      context, translate, theme, menuState.dishes);
                } else if (menuState is MenuAnalysisFailure) {
                  return _buildErrorView(
                      context, translate, theme, menuState.message);
                } else {
                  return _buildLoadingView(context, translate, theme, 0.0);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingView(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    double progress,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20).copyWith(bottom: 50),
      child: Column(
        children: [
          // Image Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Processing Steps
          _buildProcessingSteps(context, translate, theme, progress),
        ],
      ),
    );
  }

  Widget _buildProcessingSteps(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    double progress,
  ) {
    final steps = [
      (translate('step_image_processing'), 0.0, 0.2),
      (translate('step_text_extraction'), 0.2, 0.5),
      (translate('step_translation'), 0.5, 0.8),
      (translate('step_cultural_analysis'), 0.8, 1.0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('processing_steps'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final (stepName, startProgress, endProgress) = entry.value;
          final isCompleted = progress > endProgress;
          final isActive = progress >= startProgress && progress <= endProgress;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : isActive
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted
                    ? theme.colorScheme.primary
                    : isActive
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : isActive
                            ? theme.colorScheme.primary.withOpacity(0.5)
                            : theme.colorScheme.outline.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                      : isActive
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stepName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCompleted || isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    List<Dish> dishes,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20).copyWith(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('analysis_complete'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${translate('found_dishes')}: ${dishes.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Image Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dishes List
          ...dishes
              .map((dish) => _buildDishCard(context, translate, theme, dish)),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  height: 50,
                  text: translate('scan_another'),
                  icon: Icons.camera_alt_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    Dish dish,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish Names
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.translatedName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (dish.originalName != dish.translatedName) ...[
                      const SizedBox(height: 4),
                      Text(
                        dish.originalName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(dish.confidence, theme)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(dish.confidence * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getConfidenceColor(dish.confidence, theme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cultural Description
          if (dish.culturalDescription.isNotEmpty) ...[
            Text(
              dish.culturalDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Dietary Tags
          if (dish.dietaryTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dish.dietaryTags
                  .map((tag) => DietaryChip(label: tag))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Allergen Warnings
          if (dish.detectedAllergens.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${translate('allergen_warning')}: ${dish.detectedAllergens.join(', ')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    String errorMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            translate('analysis_failed'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: translate('try_again'),
                  icon: Icons.refresh_rounded,
                  onPressed: _startAnalysis,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: translate('go_back'),
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence, ThemeData theme) {
    if (confidence >= 0.8) return theme.colorScheme.primary;
    if (confidence >= 0.6) return Colors.orange;
    return theme.colorScheme.error;
  }
}
