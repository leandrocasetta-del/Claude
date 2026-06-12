import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthController(this._service) : super(const AuthState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final logged = await _service.isLoggedIn();
    state = state.copyWith(isAuthenticated: logged);
  }

  Future<bool> login(String cpf, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = await _service.login(cpf, password);
    state = state.copyWith(
      isAuthenticated: ok,
      isLoading: false,
      error: ok ? null : 'CPF/e-mail ou senha invalidos',
    );
    return ok;
  }

  Future<bool> loginWithBiometric() async {
    if (!await _service.isBiometricEnabled()) return false;
    final ok = await _service.authenticateWithBiometric();
    if (ok) {
      state = state.copyWith(isAuthenticated: true, error: null);
    }
    return ok;
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authServiceProvider)),
);

final biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.read(authServiceProvider).isBiometricAvailable(),
);

final biometricEnabledProvider = FutureProvider<bool>(
  (ref) => ref.read(authServiceProvider).isBiometricEnabled(),
);

final notificationsEnabledProvider = FutureProvider<bool>(
  (ref) => ref.read(notificationServiceProvider).isEnabled(),
);
