import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/dish.dart';
import '../repositories/gemma_repository.dart';

@injectable
class AnalyzeMenuUseCase {
  final GemmaRepository repository;

  const AnalyzeMenuUseCase(this.repository);

  Future<List<Dish>> call(AnalyzeMenuParams params) async {
    if (!repository.isModelInitialized) {
      await repository.initializeModel();
    }

    return await repository.analyzeMenuImage(
      params.imageBytes,
      params.targetLanguage,
      params.userAllergies,
    );
  }
}

class AnalyzeMenuParams extends Equatable {
  final Uint8List imageBytes;
  final String targetLanguage;
  final List<String> userAllergies;

  const AnalyzeMenuParams({
    required this.imageBytes,
    required this.targetLanguage,
    required this.userAllergies,
  });

  @override
  List<Object?> get props => [imageBytes, targetLanguage, userAllergies];
}
