import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/ride.dart';

class RideResult {
  final bool success;
  final String? error;
  final Ride? ride;
  const RideResult({required this.success, this.error, this.ride});
}

class RideService {
  final ApiClient _api;
  RideService(this._api);

  Future<List<Ride>> myRides() async {
    final res = await _api.dio.get(ApiConstants.rides);
    final list = (res.data['rides'] as List? ?? []);
    return list
        .map((e) => Ride.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Ride> getRide(int id) async {
    final res = await _api.dio.get(ApiConstants.rideById(id));
    return Ride.fromJson(Map<String, dynamic>.from(res.data['ride']));
  }

  Future<RideResult> createRide({
    required String pickupLocation,
    required String dropoffLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.rides,
        data: {
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          if (pickupLat != null) 'pickup_latitude': pickupLat,
          if (pickupLng != null) 'pickup_longitude': pickupLng,
          if (dropoffLat != null) 'dropoff_latitude': dropoffLat,
          if (dropoffLng != null) 'dropoff_longitude': dropoffLng,
        },
      );
      if (res.statusCode == 201) {
        return RideResult(
          success: true,
          ride: Ride.fromJson(Map<String, dynamic>.from(res.data['ride'])),
        );
      }
      return RideResult(success: false, error: _msg(res.data));
    } on DioException catch (e) {
      return RideResult(success: false, error: e.message ?? 'Network error');
    }
  }

  Future<RideResult> cancelRide(int id) async {
    try {
      final res = await _api.dio.post(ApiConstants.cancelRide(id));
      if (res.statusCode == 200) {
        return RideResult(
          success: true,
          ride: Ride.fromJson(Map<String, dynamic>.from(res.data['ride'])),
        );
      }
      return RideResult(success: false, error: _msg(res.data));
    } on DioException catch (e) {
      return RideResult(success: false, error: e.message ?? 'Network error');
    }
  }

  Future<RideResult> rateRide({
    required int id,
    required int score,
    String? comment,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.rateRide(id),
        data: {
          'score': score,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      if (res.statusCode == 201) {
        return const RideResult(success: true);
      }
      return RideResult(success: false, error: _msg(res.data));
    } on DioException catch (e) {
      return RideResult(success: false, error: e.message ?? 'Network error');
    }
  }

  String _msg(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'];
    return 'Something went wrong';
  }
}
