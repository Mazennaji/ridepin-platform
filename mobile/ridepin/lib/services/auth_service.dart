import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthResult {
  final bool success;
  final String? error;
  final AppUser? user;
  const AuthResult({required this.success, this.error, this.user});
}

class AuthService {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthService(this._api, this._storage);

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      if (res.statusCode == 200 && res.data['token'] != null) {
        return _persist(res.data);
      }
      return AuthResult(
        success: false,
        error: _msg(res.data, fallback: 'Invalid credentials'),
      );
    } on DioException catch (e) {
      return AuthResult(success: false, error: _dioMsg(e));
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };
      final res = await _api.dio.post(ApiConstants.register, data: data);
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['token'] != null) {
        return _persist(res.data);
      }
      return AuthResult(
        success: false,
        error: _msg(res.data, fallback: 'Registration failed'),
      );
    } on DioException catch (e) {
      return AuthResult(success: false, error: _dioMsg(e));
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post(ApiConstants.logout);
    } catch (_) {
    } finally {
      await _storage.clear();
    }
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final res = await _api.dio.get(ApiConstants.profile);
      if (res.statusCode == 200 && res.data['user'] is Map) {
        return Map<String, dynamic>.from(res.data['user']);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<AuthResult> _persist(Map<String, dynamic> data) async {
    final user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
    await _storage.saveAuth(
      token: data['token'] as String,
      userId: user.id,
      role: user.roleName ?? '',
      name: user.name,
      email: user.email,
    );
    return AuthResult(success: true, user: user);
  }

  String _msg(dynamic data, {required String fallback}) {
    if (data is Map && data['message'] is String) return data['message'];
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return fallback;
  }

  String _dioMsg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check the API URL and that Laravel is running.';
    }
    return e.message ?? 'Network error';
  }
}
