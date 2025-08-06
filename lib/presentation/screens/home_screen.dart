import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/custom_button.dart';
import '../cubits/user_preferences_cubit.dart';
import '../cubits/translation_cubit.dart';
import 'menu_analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Load user preferences
    final preferencesCubit = BlocProvider.of<UserPreferencesCubit>(context);
    await preferencesCubit.loadPreferences();

    // Initialize translations
    if (!mounted) return;
    final translationCubit = BlocProvider.of<TranslationCubit>(context);
    await translationCubit.initializeTranslations();

    // Set language from preferences
    final preferredLanguage = preferencesCubit.preferredLanguage;
    if (preferredLanguage != translationCubit.currentLanguage) {
      await translationCubit.changeLanguage(preferredLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, translationState) {
        return BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
          builder: (context, preferencesState) {
            final theme = Theme.of(context);

            // Get current language for RTL detection
            final isRTL = translationState is TranslationLoaded &&
                TranslationCubit.rtlLanguages.contains(
                  translationState.currentLanguage,
                );

            // Get translation function
            String translate(String key) {
              if (translationState is TranslationLoaded) {
                final pack = translationState
                    .languagePacks[translationState.currentLanguage];
                return pack?.translations[key] ?? key;
              }
              return key;
            }

            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: theme.colorScheme.surface,
                appBar: AppBar(
                  title: Text(
                    translate('app_title'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.settings_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => _navigateToSettings(context),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(context, translate, theme),

                      const SizedBox(height: 40),

                      // Main Action Button
                      _buildScanButton(context, translate, theme),

                      const SizedBox(height: 30),

                      // Features Grid
                      _buildFeaturesGrid(context, translate, theme),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('welcome_title'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translate('welcome_subtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    return CustomButton(
      text: translate('scan_menu'),
      icon: Icons.camera_alt_rounded,
      onPressed: () => _showImagePickerBottomSheet(context, translate),
      height: 56,
    );
  }

  Widget _buildFeaturesGrid(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('features_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildFeatureCard(
              icon: Icons.translate_rounded,
              title: translate('feature_translate'),
              subtitle: translate('feature_translate_desc'),
              color: theme.colorScheme.primary,
              theme: theme,
            ),
            _buildFeatureCard(
              icon: Icons.health_and_safety_rounded,
              title: translate('feature_allergens'),
              subtitle: translate('feature_allergens_desc'),
              color: theme.colorScheme.secondary,
              theme: theme,
            ),
            _buildFeatureCard(
              icon: Icons.language_rounded,
              title: translate('feature_cultural'),
              subtitle: translate('feature_cultural_desc'),
              color: theme.colorScheme.tertiary,
              theme: theme,
            ),
            _buildFeatureCard(
              icon: Icons.restaurant_menu_rounded,
              title: translate('feature_ingredients'),
              subtitle: translate('feature_ingredients_desc'),
              color: theme.colorScheme.error,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansSection(
    BuildContext context,
    String Function(String) translate,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('recent_scans'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to history screen
              },
              child: Text(
                translate('view_all'),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  translate('no_recent_scans'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerBottomSheet(
    BuildContext context,
    String Function(String) translate,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                    translate('select_image_source'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Camera option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    title: translate('take_photo'),
                    subtitle: translate('take_photo_desc'),
                    onTap: () => _pickImageFromCamera(context),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Gallery option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    title: translate('choose_from_gallery'),
                    subtitle: translate('choose_from_gallery_desc'),
                    onTap: () => _pickImageFromGallery(context),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        final Uint8List imageBytes = await image.readAsBytes();
        _processSelectedImage(imageBytes);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to take photo: $e');
      }
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        final Uint8List imageBytes = await image.readAsBytes();
        _processSelectedImage(imageBytes);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to select image: $e');
      }
    }
  }

  void _processSelectedImage(Uint8List imageBytes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuAnalysisScreen(imageBytes: imageBytes),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }
}
