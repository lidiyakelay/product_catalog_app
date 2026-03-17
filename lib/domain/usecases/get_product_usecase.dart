import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductUseCase implements UseCase<Product, int> {
  final ProductRepository repository;

  const GetProductUseCase(this.repository);

  @override
  Future<Product> call(int id) {
    return repository.getProduct(id);
  }
}
