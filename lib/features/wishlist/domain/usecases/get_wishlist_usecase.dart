import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getWishlist();
  }
}
