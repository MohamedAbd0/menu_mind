import 'package:injectable/injectable.dart';
import '../entities/user_preferences.dart';
import '../repositories/gemma_repository.dart';

@injectable
class ManageUserPreferencesUseCase {
  final GemmaRepository repository;

  const ManageUserPreferencesUseCase(this.repository);

  Future<UserPreferences> loadPreferences() async {
    return await repository.loadUserPreferences();
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await repository.saveUserPreferences(preferences);
  }

  Future<void> updateAllergies(List<String> allergies) async {
    final currentPrefs = await loadPreferences();
    final updatedPrefs = currentPrefs.copyWith(allergies: allergies);
    await savePreferences(updatedPrefs);
  }

  Future<void> updateLanguage(String languageCode) async {
    final currentPrefs = await loadPreferences();
    final updatedPrefs = currentPrefs.copyWith(preferredLanguage: languageCode);
    await savePreferences(updatedPrefs);
  }

  Future<void> updateVoiceEnabled(bool enabled) async {
    final currentPrefs = await loadPreferences();
    final updatedPrefs = currentPrefs.copyWith(voiceEnabled: enabled);
    await savePreferences(updatedPrefs);
  }

  Future<void> updateDarkMode(bool enabled) async {
    final currentPrefs = await loadPreferences();
    final updatedPrefs = currentPrefs.copyWith(darkMode: enabled);
    await savePreferences(updatedPrefs);
  }

  Future<void> completeFirstLaunch() async {
    final currentPrefs = await loadPreferences();
    final updatedPrefs = currentPrefs.copyWith(firstLaunch: false);
    await savePreferences(updatedPrefs);
  }

  Future<void> clearAllData() async {
    await repository.clearCache();
    await savePreferences(UserPreferences.defaultPreferences());
  }
}
