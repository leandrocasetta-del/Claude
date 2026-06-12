import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const _kTokenKey = 'auth_token';
  static const _kBiometricKey = 'biometric_enabled';
  static const _kSavedCpfKey = 'saved_cpf';

  final ApiService _api;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthService(this._api);

  Future<bool> login(String cpf, String password) async {
    final ok = await _api.login(cpf, password);
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, 'mock-token-${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString(_kSavedCpfKey, cpf);
    }
    return ok;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey) != null;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricKey, enabled);
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para acessar o app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<String?> savedCpf() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSavedCpfKey);
  }
}
