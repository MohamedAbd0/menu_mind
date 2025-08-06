import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// Cubits
import '../../data/datasources/gemma_datasource.dart';
import 'menu_cubit.dart';
import 'user_preferences_cubit.dart';
import 'translation_cubit.dart';

// Data Sources & Repositories
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/repositories/gemma_repository_impl.dart';

// Use Cases
import '../../domain/usecases/analyze_menu_usecase.dart';
import '../../domain/usecases/translate_ui_usecase.dart';

class CubitSetup {
  static Future<List<BlocProvider>> createCubits() async {
    // Initialize data sources
    final localStorageDataSource = LocalStorageDataSource();
    await localStorageDataSource.initialize();

    final gemmaDataSource = GemmaDataSource();

    // Initialize repositories
    final gemmaRepository = GemmaRepositoryImpl(
      localDataSource: localStorageDataSource,
      gemmaDataSource: gemmaDataSource,
    );

    // Initialize use cases
    final analyzeMenuUseCase = AnalyzeMenuUseCase(gemmaRepository);
    final translateUIUseCase = TranslateUIUseCase(gemmaRepository);

    return [
      // User Preferences Cubit
      BlocProvider<UserPreferencesCubit>(
        create: (_) => UserPreferencesCubit(
          localStorageDataSource: localStorageDataSource,
        ),
      ),

      // Menu Analysis Cubit
      BlocProvider<MenuCubit>(
        create: (_) => MenuCubit(analyzeMenuUseCase: analyzeMenuUseCase),
      ),

      // Translation Cubit
      BlocProvider<TranslationCubit>(
        create: (_) => TranslationCubit(
          translateUIUseCase: translateUIUseCase,
          localStorageDataSource: localStorageDataSource,
        ),
      ),
    ];
  }

  static Widget wrapWithCubits({
    required Widget child,
    required List<BlocProvider> cubits,
  }) {
    return MultiBlocProvider(providers: cubits, child: child);
  }
}

// Helper extension for easy cubit access
extension CubitExtensions on BuildContext {
  MenuCubit get menuCubit => BlocProvider.of<MenuCubit>(this);
  UserPreferencesCubit get preferencesCubit =>
      BlocProvider.of<UserPreferencesCubit>(this);
  TranslationCubit get translationCubit =>
      BlocProvider.of<TranslationCubit>(this);

  // Watch versions for reactive updates
  MenuCubit watchMenuCubit() => BlocProvider.of<MenuCubit>(this);
  UserPreferencesCubit watchPreferencesCubit() =>
      BlocProvider.of<UserPreferencesCubit>(this);
  TranslationCubit watchTranslationCubit() =>
      BlocProvider.of<TranslationCubit>(this);
}
