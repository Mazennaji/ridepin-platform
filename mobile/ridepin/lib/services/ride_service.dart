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

class FareEstimate {
  final double fare;
  final double distance;
  const FareEstimate({required this.fare, required this.distance});
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

  Future<FareEstimate?> estimate({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.estimate,
        data: {
          'pickup_latitude': pickupLat,
          'pickup_longitude': pickupLng,
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
        },
      );
      if (res.statusCode == 200) {
        return FareEstimate(
          fare: (res.data['fare'] as num).toDouble(),
          distance: (res.data['distance'] as num).toDouble(),
        );
      }
      return null;
    } on DioException {
      return null;
    }
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
      final data = <String, dynamic>{
        'pickup_location': pickupLocation,
        'dropoff_location': dropoffLocation,
      };
      if (pickupLat != null) data['pickup_latitude'] = pickupLat;
      if (pickupLng != null) data['pickup_longitude'] = pickupLng;
      if (dropoffLat != null) data['dropoff_latitude'] = dropoffLat;
      if (dropoffLng != null) data['dropoff_longitude'] = dropoffLng;

      final res = await _api.dio.post(ApiConstants.rides, data: data);
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
      final data = <String, dynamic>{'score': score};
      if (comment != null && comment.isNotEmpty) data['comment'] = comment;

      final res = await _api.dio.post(ApiConstants.rateRide(id), data: data);
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
