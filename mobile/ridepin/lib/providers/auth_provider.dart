import 'package:flutter/foundation.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _storage;

  AuthProvider(this._authService, this._storage);

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _role;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get role => _role;
  bool get loading => _loading;
  String? get error => _error;

  bool get isRider => _role == 'rider';
  bool get isDriver => _role == 'driver';

  Future<void> bootstrap() async {
    final loggedIn = await _storage.isLoggedIn();
    if (loggedIn) {
      _role = await _storage.getRole();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final res = await _authService.login(email: email, password: password);
    _applyResult(res);
    _setLoading(false);
    return res.success;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    final res = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      phone: phone,
    );
    _applyResult(res);
    _setLoading(false);
    return res.success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _role = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _applyResult(AuthResult res) {
    if (res.success && res.user != null) {
      _user = res.user;
      _role = res.user!.roleName;
      _status = AuthStatus.authenticated;
      _error = null;
    } else {
      _error = res.error;
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
