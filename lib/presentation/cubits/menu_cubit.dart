import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/dish.dart';
import '../../domain/usecases/analyze_menu_usecase.dart';

// States
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {
  final double progress;

  const MenuLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class MenuAnalysisSuccess extends MenuState {
  final List<Dish> dishes;

  const MenuAnalysisSuccess(this.dishes);

  @override
  List<Object?> get props => [dishes];
}

class MenuAnalysisFailure extends MenuState {
  final String message;

  const MenuAnalysisFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class MenuCubit extends Cubit<MenuState> {
  final AnalyzeMenuUseCase _analyzeMenuUseCase;

  MenuCubit({required AnalyzeMenuUseCase analyzeMenuUseCase})
      : _analyzeMenuUseCase = analyzeMenuUseCase,
        super(MenuInitial());

  bool get isLoading => state is MenuLoading;
  bool get hasError => state is MenuAnalysisFailure;
  bool get hasDishes => state is MenuAnalysisSuccess;

  List<Dish> get dishes {
    if (state is MenuAnalysisSuccess) {
      return (state as MenuAnalysisSuccess).dishes;
    }
    return [];
  }

  String? get errorMessage {
    if (state is MenuAnalysisFailure) {
      return (state as MenuAnalysisFailure).message;
    }
    return null;
  }

  double get progress {
    if (state is MenuLoading) {
      return (state as MenuLoading).progress;
    }
    return 0.0;
  }

  Future<void> analyzeMenu({
    required Uint8List imageBytes,
    required String targetLanguage,
    required List<String> userAllergies,
  }) async {
    try {
      final params = AnalyzeMenuParams(
        imageBytes: imageBytes,
        targetLanguage: targetLanguage,
        userAllergies: userAllergies,
      );

      emit(const MenuLoading(progress: 0.8));

      final dishes = await _analyzeMenuUseCase(params);

      emit(MenuAnalysisSuccess(dishes));
    } catch (e) {
      emit(MenuAnalysisFailure(e.toString()));
    }
  }

  void clearResults() {
    emit(MenuInitial());
  }

  void retryAnalysis({
    required Uint8List imageBytes,
    required String targetLanguage,
    required List<String> userAllergies,
  }) {
    analyzeMenu(
      imageBytes: imageBytes,
      targetLanguage: targetLanguage,
      userAllergies: userAllergies,
    );
  }
}
