import 'package:injectable/injectable.dart';
import '../../data/datasources/gemma_datasource.dart';

@injectable
class ModelLoaderService {
  final GemmaDataSource _gemmaDataSource;

  ModelLoaderService(this._gemmaDataSource);

  bool get isModelInitialized => _gemmaDataSource.isInitialized;

  Future<void> initializeModel({
    Function(String)? onStatusUpdate,
    Function(double?)? onProgress,
  }) async {
    await _gemmaDataSource.initialize(
      onStatusUpdate: onStatusUpdate,
      onProgress: onProgress,
    );
  }

  Future<void> dispose() async {
    _gemmaDataSource.dispose();
  }
}
