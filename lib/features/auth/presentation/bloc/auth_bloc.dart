import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final failureOrAuthResponse = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    failureOrAuthResponse.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) => emit(AuthAuthenticated(user: authResponse.user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final failureOrAuthResponse = await registerUseCase(
      RegisterParams(email: event.email, password: event.password, name: event.name),
    );

    failureOrAuthResponse.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) => emit(AuthAuthenticated(user: authResponse.user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final failureOrSuccess = await logoutUseCase(NoParams());

    failureOrSuccess.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onGetCurrentUser(GetCurrentUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final failureOrUser = await getCurrentUserUseCase(NoParams());

    failureOrUser.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  String _mapFailureToMessage(dynamic failure) {
    // Tạm thời xuất toString() do Failure chưa override map to Message.
    // Thực tế có thể check kiểu `if (failure is ServerFailure) return failure.message;` 
    // do ta có thuộc tính message cho tất cả Failures.
    try {
      return failure.message as String;
    } catch (e) {
      return 'Unexpected error occurred.';
    }
  }
}
