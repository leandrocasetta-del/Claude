import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kTokenKey = 'auth_token';
  static const _kBiometricKey = 'biometric_enabled';
  static const _kSavedLoginKey = 'saved_login';

  static const _validCpf = '32843725801';
  static const _validCpfFormatted = '328.437.258-01';
  static const _validPassword = 'pentium';

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> login(String loginInput, String password) async {
    final normalized = loginInput.replaceAll(RegExp(r'[.\-\s]'), '');
    final isValidUser =
        normalized == _validCpf || loginInput.trim() == _validCpfFormatted;
    final ok = isValidUser && password == _validPassword;
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kTokenKey,
        'token-${DateTime.now().millisecondsSinceEpoch}',
      );
      await prefs.setString(_kSavedLoginKey, loginInput);
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

  Future<String?> savedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSavedLoginKey);
  }
}
