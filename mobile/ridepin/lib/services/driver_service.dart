import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/ride.dart';

class DriverActionResult {
  final bool success;
  final String? error;
  final Ride? ride;
  const DriverActionResult({required this.success, this.error, this.ride});
}

class DriverService {
  final ApiClient _api;
  DriverService(this._api);

  Future<List<Ride>> availableRides() async {
    final res = await _api.dio.get(ApiConstants.availableRides);
    final list = (res.data['rides'] as List? ?? []);
    return list
        .map((e) => Ride.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DriverActionResult> accept(int id) =>
      _transition(ApiConstants.acceptRide(id));
  Future<DriverActionResult> start(int id) =>
      _transition(ApiConstants.startRide(id));
  Future<DriverActionResult> complete(int id) =>
      _transition(ApiConstants.completeRide(id));

  Future<DriverActionResult> _transition(String path) async {
    try {
      final res = await _api.dio.post(path);
      if (res.statusCode == 200) {
        return DriverActionResult(
          success: true,
          ride: Ride.fromJson(Map<String, dynamic>.from(res.data['ride'])),
        );
      }
      return DriverActionResult(success: false, error: _msg(res.data));
    } on DioException catch (e) {
      return DriverActionResult(
        success: false,
        error: e.message ?? 'Network error',
      );
    }
  }

  Future<bool> toggleAvailability(bool isAvailable) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.toggleAvailability,
        data: {'is_available': isAvailable},
      );
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  String _msg(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'];
    return 'Something went wrong';
  }
}
