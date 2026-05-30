import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC managing authentication state throughout the app
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final RegisterUseCase _registerUseCase;
  final SignOutUseCase _signOutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AnalyticsService _analyticsService;

  StreamSubscription? _authSubscription;

  AuthBloc(
    this._signInUseCase,
    this._registerUseCase,
    this._signOutUseCase,
    this._forgotPasswordUseCase,
    this._getCurrentUserUseCase,
    this._analyticsService,
  ) : super(const AuthState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthSignInEvent>(_onSignIn);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthForgotPasswordEvent>(_onForgotPassword);
    on<AuthUserChangedEvent>(_onUserChanged);

    // Start listening to auth state changes
    _startAuthListener();
  }

  void _startAuthListener() {
    _authSubscription = _getCurrentUserUseCase.authStream.listen(
      (user) {
        add(AuthUserChangedEvent(user));
      },
    );
  }

  void _onUserChanged(AuthUserChangedEvent event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      // Update FCM token and analytics
      _analyticsService.setUserId(user.uid);
      _updateFcmToken(user.uid);
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      _analyticsService.clearUser();
    }
  }

  Future<void> _updateFcmToken(String uid) async {
    // Skipped per user request (upgraded Firebase plan not available)
    return;
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      },
    );
  }

  Future<void> _onSignIn(
    AuthSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        _analyticsService.logLogin();
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        phone: event.phone,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        _analyticsService.logSignUp();
      },
    );
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.unauthenticated, user: null)),
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result =
        await _forgotPasswordUseCase(ForgotPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.passwordResetSent,
        resetEmail: event.email,
      )),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
