import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiServiceProvider)),
);

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
    try {
      final ok = await _service.login(cpf, password);
      state = state.copyWith(
        isAuthenticated: ok,
        isLoading: false,
        error: ok ? null : 'CPF ou senha invalidos',
      );
      return ok;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
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

final userProvider = FutureProvider<UserProfile>(
  (ref) => ref.read(apiServiceProvider).fetchUser(),
);

final appointmentsProvider = FutureProvider<List<Appointment>>(
  (ref) => ref.read(apiServiceProvider).fetchAppointments(),
);

final examTypesProvider = FutureProvider<List<ExamType>>(
  (ref) => ref.read(apiServiceProvider).fetchExamTypes(),
);

final resultsProvider = FutureProvider<List<ExamResult>>(
  (ref) => ref.read(apiServiceProvider).fetchResults(),
);

final unitsProvider = FutureProvider<List<Unit>>(
  (ref) => ref.read(apiServiceProvider).fetchUnits(),
);
