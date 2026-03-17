import '../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class GetCategoriesUseCase implements UseCase<List<String>, NoParams> {
  final ProductRepository repository;

  const GetCategoriesUseCase(this.repository);

  @override
  Future<List<String>> call(NoParams params) {
    return repository.getCategories();
  }
}
