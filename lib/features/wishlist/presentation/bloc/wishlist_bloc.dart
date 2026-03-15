import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/toggle_wishlist_usecase.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;

  WishlistBloc({
    required this.getWishlistUseCase,
    required this.toggleWishlistUseCase,
  }) : super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
  }

  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    final failureOrWishlist = await getWishlistUseCase(NoParams());
    
    failureOrWishlist.fold(
      (failure) => emit(WishlistError(message: failure.message)),
      (wishlist) {
        final wishlistIds = wishlist.map((e) => e.id).toList();
        emit(WishlistLoaded(wishlist: wishlist, wishlistIds: wishlistIds));
      },
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistActionInProgress());
    final failureOrIds = await toggleWishlistUseCase(event.productId);
    
    await failureOrIds.fold(
      (failure) async => emit(WishlistError(message: failure.message)),
      (wishlistIds) async {
        final isAdded = wishlistIds.contains(event.productId);
        emit(WishlistToggleSuccess(
          message: isAdded ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích',
          isAdded: isAdded,
          wishlistIds: wishlistIds,
        ));

        // After toggle, reload full wishlist to keep UI in sync
        final failureOrWishlist = await getWishlistUseCase(NoParams());
        failureOrWishlist.fold(
          (failure) => emit(WishlistError(message: failure.message)),
          (wishlist) => emit(WishlistLoaded(wishlist: wishlist, wishlistIds: wishlistIds)),
        );
      },
    );
  }
}
