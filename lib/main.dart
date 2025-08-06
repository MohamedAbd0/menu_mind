import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'presentation/cubits/user_preferences_cubit.dart';
import 'presentation/cubits/translation_cubit.dart';
import 'presentation/cubits/menu_cubit.dart';
import 'presentation/screens/model_initialization_screen.dart';
import 'data/datasources/local_storage_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure dependencies
  configureDependencies();

  // Initialize local storage
  await getIt<LocalStorageDataSource>().initialize();

  runApp(const MenuMindApp());
}

class MenuMindApp extends StatelessWidget {
  const MenuMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserPreferencesCubit>(
          create: (context) => getIt<UserPreferencesCubit>(),
        ),
        BlocProvider<TranslationCubit>(
          create: (context) => getIt<TranslationCubit>(),
        ),
        BlocProvider<MenuCubit>(create: (context) => getIt<MenuCubit>()),
      ],
      child: BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
        builder: (context, state) {
          final isDarkMode = state is UserPreferencesLoaded
              ? state.preferences.darkMode
              : false;

          return MaterialApp(
            title: 'MenuMind',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const ModelInitializationScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(
                      context,
                    ).textScaler.scale(1.0).clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
