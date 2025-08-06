import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_preferences.dart';
import '../../data/datasources/local_storage_datasource.dart';

// States
abstract class UserPreferencesState extends Equatable {
  const UserPreferencesState();

  @override
  List<Object?> get props => [];
}

class UserPreferencesInitial extends UserPreferencesState {}

class UserPreferencesLoading extends UserPreferencesState {}

class UserPreferencesLoaded extends UserPreferencesState {
  final UserPreferences preferences;

  const UserPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UserPreferencesError extends UserPreferencesState {
  final String message;

  const UserPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class UserPreferencesCubit extends Cubit<UserPreferencesState> {
  final LocalStorageDataSource _localStorageDataSource;

  UserPreferencesCubit({required LocalStorageDataSource localStorageDataSource})
    : _localStorageDataSource = localStorageDataSource,
      super(UserPreferencesInitial());

  UserPreferences? get preferences {
    if (state is UserPreferencesLoaded) {
      return (state as UserPreferencesLoaded).preferences;
    }
    return null;
  }

  bool get isLoading => state is UserPreferencesLoading;
  bool get hasError => state is UserPreferencesError;

  // Getters for easy access
  String get preferredLanguage => preferences?.preferredLanguage ?? 'en';
  bool get isDarkMode => preferences?.darkMode ?? false;
  List<String> get allergies => preferences?.allergies ?? [];
  bool get enableSound => preferences?.voiceEnabled ?? true;
  bool get enableVibration => preferences?.voiceEnabled ?? true;
  bool get firstLaunch => preferences?.firstLaunch ?? true;

  Future<void> loadPreferences() async {
    try {
      emit(UserPreferencesLoading());
      final prefs = await _localStorageDataSource.getUserPreferences();
      emit(UserPreferencesLoaded(prefs));
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> updateLanguage(String language) async {
    if (preferences != null) {
      final updatedPreferences = preferences!.copyWith(
        preferredLanguage: language,
      );
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> toggleDarkMode(bool isDark) async {
    if (preferences != null) {
      final updatedPreferences = preferences!.copyWith(darkMode: isDark);
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> updateAllergies(List<String> allergies) async {
    if (preferences != null) {
      final updatedPreferences = preferences!.copyWith(allergies: allergies);
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> addAllergy(String allergy) async {
    if (preferences != null && !preferences!.allergies.contains(allergy)) {
      final updatedAllergies = [...preferences!.allergies, allergy];
      final updatedPreferences = preferences!.copyWith(
        allergies: updatedAllergies,
      );
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> removeAllergy(String allergy) async {
    if (preferences != null) {
      final updatedAllergies = preferences!.allergies
          .where((a) => a != allergy)
          .toList();
      final updatedPreferences = preferences!.copyWith(
        allergies: updatedAllergies,
      );
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> toggleSound(bool enable) async {
    if (preferences != null) {
      final updatedPreferences = preferences!.copyWith(voiceEnabled: enable);
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> toggleVibration(bool enable) async {
    if (preferences != null) {
      // For now, this updates voiceEnabled as we don't have a separate vibration setting
      final updatedPreferences = preferences!.copyWith(voiceEnabled: enable);
      await _savePreferences(updatedPreferences);
    }
  }

  Future<void> _savePreferences(UserPreferences preferences) async {
    try {
      emit(UserPreferencesLoading());
      await _localStorageDataSource.saveUserPreferences(preferences);
      emit(UserPreferencesLoaded(preferences));
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> resetToDefaults() async {
    const defaultPreferences = UserPreferences(
      preferredLanguage: 'en',
      darkMode: false,
      allergies: [],
      voiceEnabled: true,
      firstLaunch: false,
    );
    await _savePreferences(defaultPreferences);
  }
}
