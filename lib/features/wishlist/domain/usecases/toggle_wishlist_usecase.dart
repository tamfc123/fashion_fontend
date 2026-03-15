import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/wishlist_repository.dart';

class ToggleWishlistUseCase implements UseCase<List<String>, String> {
  final WishlistRepository repository;

  ToggleWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String productId) async {
    return await repository.toggleWishlist(productId);
  }
}
