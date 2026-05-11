import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  }) : _authRepository = authRepository,
       _tokenStorage = tokenStorage,
       super(AuthState.initial());

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  Future<void> bootstrap() async {
    final onboardingSeen = await _tokenStorage.isOnboardingSeen();
    final hasValidToken = await _tokenStorage.hasValidAccessToken();
    final role = await _tokenStorage.readUserRole();

    if (!onboardingSeen) {
      _log('bootstrap -> unauthenticated (onboarding not seen)');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          onboardingSeen: false,
          clearError: true,
        ),
      );
      return;
    }

    if (hasValidToken) {
      _log('bootstrap -> authenticated (valid token, role=$role)');
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          onboardingSeen: true,
          userRole: role,
          clearError: true,
        ),
      );
      return;
    }

    await _tokenStorage.clearTokens();
    _log('bootstrap -> unauthenticated (token missing/expired)');
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        onboardingSeen: true,
        clearError: true,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    await _tokenStorage.setOnboardingSeen();
    emit(
      state.copyWith(
        onboardingSeen: true,
        status: AuthStatus.unauthenticated,
        clearError: true,
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    _log('login start: email=$email');
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );
      await _persistSession(session);
      _log('login success: role=${session.role}');
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          onboardingSeen: true,
          isSubmitting: false,
          userEmail: session.email,
          userFullName: session.fullName,
          userRole: session.role,
          clearError: true,
        ),
      );
    } on ApiException catch (e) {
      _log('login api error: ${e.message} (${e.errorCode})');
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      _log('login unknown error');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Không thể đăng nhập',
        ),
      );
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _log('register start: email=$email');
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      await _persistSession(session);
      _log('register success: role=${session.role}');
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          onboardingSeen: true,
          isSubmitting: false,
          userEmail: session.email,
          userFullName: session.fullName,
          userRole: session.role,
          clearError: true,
        ),
      );
    } on ApiException catch (e) {
      _log('register api error: ${e.message} (${e.errorCode})');
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      _log('register unknown error');
      emit(
        state.copyWith(isSubmitting: false, errorMessage: 'Không thể đăng ký'),
      );
    }
  }

  Future<void> logout() async {
    _log('logout start');
    emit(state.copyWith(isSubmitting: true, clearError: true));
    await _authRepository.logout();
    await _tokenStorage.clearTokens();
    _log('logout success');
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        onboardingSeen: true,
        isSubmitting: false,
        userEmail: null,
        userFullName: null,
        userRole: null,
        clearError: true,
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _persistSession(AuthSession session) async {
    await _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresIn: session.accessTokenExpiresIn,
      userRole: session.role,
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AUTH] $message');
    }
  }
}
