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
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );
      await _persistSession(session);
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
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
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
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(isSubmitting: false, errorMessage: 'Không thể đăng ký'),
      );
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    await _authRepository.logout();
    await _tokenStorage.clearTokens();
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
}
