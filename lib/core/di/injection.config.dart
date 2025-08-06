// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/gemma_datasource.dart' as _i37;
import '../../data/datasources/local_storage_datasource.dart' as _i82;
import '../../data/repositories/gemma_repository_impl.dart' as _i791;
import '../../domain/repositories/gemma_repository.dart' as _i175;
import '../../domain/services/model_loader_service.dart' as _i285;
import '../../domain/usecases/analyze_menu_usecase.dart' as _i403;
import '../../domain/usecases/manage_user_preferences_usecase.dart' as _i402;
import '../../domain/usecases/predict_ingredients_usecase.dart' as _i155;
import '../../domain/usecases/translate_ui_usecase.dart' as _i518;
import '../../presentation/cubits/menu_cubit.dart' as _i1053;
import '../../presentation/cubits/translation_cubit.dart' as _i364;
import '../../presentation/cubits/user_preferences_cubit.dart' as _i262;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i37.GemmaDataSource>(() => _i37.GemmaDataSource());
    gh.factory<_i82.LocalStorageDataSource>(
        () => _i82.LocalStorageDataSource());
    gh.factory<_i285.ModelLoaderService>(
        () => _i285.ModelLoaderService(gh<_i37.GemmaDataSource>()));
    gh.factory<_i262.UserPreferencesCubit>(() => _i262.UserPreferencesCubit(
        localStorageDataSource: gh<_i82.LocalStorageDataSource>()));
    gh.factory<_i175.GemmaRepository>(() => _i791.GemmaRepositoryImpl(
          localDataSource: gh<_i82.LocalStorageDataSource>(),
          gemmaDataSource: gh<_i37.GemmaDataSource>(),
        ));
    gh.factory<_i402.ManageUserPreferencesUseCase>(
        () => _i402.ManageUserPreferencesUseCase(gh<_i175.GemmaRepository>()));
    gh.factory<_i518.TranslateUIUseCase>(
        () => _i518.TranslateUIUseCase(gh<_i175.GemmaRepository>()));
    gh.factory<_i403.AnalyzeMenuUseCase>(
        () => _i403.AnalyzeMenuUseCase(gh<_i175.GemmaRepository>()));
    gh.factory<_i155.PredictIngredientsUseCase>(
        () => _i155.PredictIngredientsUseCase(gh<_i175.GemmaRepository>()));
    gh.factory<_i364.TranslationCubit>(() => _i364.TranslationCubit(
          translateUIUseCase: gh<_i518.TranslateUIUseCase>(),
          localStorageDataSource: gh<_i82.LocalStorageDataSource>(),
        ));
    gh.factory<_i1053.MenuCubit>(() =>
        _i1053.MenuCubit(analyzeMenuUseCase: gh<_i403.AnalyzeMenuUseCase>()));
    return this;
  }
}
