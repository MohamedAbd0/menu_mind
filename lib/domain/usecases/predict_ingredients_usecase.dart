import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../repositories/gemma_repository.dart';

@injectable
class PredictIngredientsUseCase {
  final GemmaRepository repository;

  const PredictIngredientsUseCase(this.repository);

  Future<List<String>> call(PredictIngredientsParams params) async {
    if (!repository.isModelInitialized) {
      await repository.initializeModel();
    }

    final ingredients = await repository.predictIngredients(
      params.dishName,
      params.originalLanguage,
    );

    return ingredients;
  }
}

class PredictIngredientsParams extends Equatable {
  final String dishName;
  final String originalLanguage;
  final List<String> userAllergies;

  const PredictIngredientsParams({
    required this.dishName,
    required this.originalLanguage,
    this.userAllergies = const [],
  });

  @override
  List<Object?> get props => [dishName, originalLanguage, userAllergies];
}
