import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/user_preferences_cubit.dart';
import '../cubits/translation_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Common allergens list
  final List<String> _availableAllergens = [
    'Milk',
    'Eggs',
    'Peanuts',
    'Tree Nuts',
    'Soy',
    'Wheat',
    'Shellfish',
    'Fish',
    'Sesame',
    'Gluten',
    'Dairy',
  ];

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
                translate('settings'),
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
            body: BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
              builder: (context, preferencesState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Settings Section
                      _buildLanguageSection(
                          context, translate, theme, translationState),
                      const SizedBox(height: 32),

                      // Allergen Settings Section
                      _buildAllergenSection(
                          context, translate, theme, preferencesState),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    TranslationState translationState,
  ) {
    final currentLanguage = translationState is TranslationLoaded
        ? translationState.currentLanguage
        : 'en';

    return _buildSection(
      title: translate('language_settings'),
      icon: Icons.language_rounded,
      theme: theme,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: ListTile(
          leading: Icon(
            Icons.translate_rounded,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            translate('preferred_language'),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            TranslationCubit.supportedLanguages[currentLanguage] ?? 'English',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergenSection(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
    UserPreferencesState preferencesState,
  ) {
    final selectedAllergens = preferencesState is UserPreferencesLoaded
        ? preferencesState.preferences.allergies
        : <String>[];

    return _buildSection(
      title: translate('allergen_settings'),
      icon: Icons.health_and_safety_rounded,
      theme: theme,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translate('my_allergies'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Select allergens you want to be warned about',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableAllergens.map((allergen) {
                    final isSelected = selectedAllergens.contains(allergen);
                    return FilterChip(
                      label: Text(allergen),
                      selected: isSelected,
                      onSelected: (selected) =>
                          _toggleAllergen(allergen, selected),
                      selectedColor: theme.colorScheme.errorContainer,
                      checkmarkColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                if (selectedAllergens.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will be warned about: ${selectedAllergens.join(', ')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    return _buildSection(
      title: translate('theme_settings'),
      icon: Icons.palette_rounded,
      theme: theme,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.dark_mode_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                translate('dark_mode'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Switch between light and dark themes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // TODO: Implement theme switching
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme switching coming soon!'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  // todo: Implement language selection logic later
  void _showLanguageSelector(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    translate('preferred_language'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Language options
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      child: Column(
                        children: TranslationCubit.supportedLanguages.entries
                            .map((entry) {
                          final languageCode = entry.key;
                          final languageName = entry.value;
                          final isSelected = context
                                  .read<TranslationCubit>()
                                  .currentLanguage ==
                              languageCode;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: theme.colorScheme.onPrimary,
                                      )
                                    : null,
                              ),
                              title: Text(
                                languageName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              onTap: () async {
                                // todo: Implement language change logic later
                                return;
                                if (!isSelected) {
                                  // Show loading indicator
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text('Loading $languageName...'),
                                        ],
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  try {
                                    // Change the language
                                    await context
                                        .read<TranslationCubit>()
                                        .changeLanguage(languageCode);

                                    // Update user preferences
                                    await context
                                        .read<UserPreferencesCubit>()
                                        .updateLanguage(languageCode);

                                    // Hide loading indicator and show success
                                    scaffoldMessenger.hideCurrentSnackBar();
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                                'Language changed to $languageName'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } catch (e) {
                                    // Hide loading indicator and show error
                                    scaffoldMessenger.hideCurrentSnackBar();
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: theme.colorScheme.onError,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 12),
                                            Text('Failed to change language'),
                                          ],
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleAllergen(String allergen, bool selected) {
    final userPreferencesCubit = context.read<UserPreferencesCubit>();
    if (selected) {
      userPreferencesCubit.addAllergy(allergen);
    } else {
      userPreferencesCubit.removeAllergy(allergen);
    }
  }
}
