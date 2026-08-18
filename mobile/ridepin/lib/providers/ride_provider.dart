import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/ride_service.dart';

class RideProvider extends ChangeNotifier {
  final RideService _rideService;
  RideProvider(this._rideService);

  List<Ride> _rides = [];
  bool _loading = false;
  String? _error;

  List<Ride> get rides => _rides;
  bool get loading => _loading;
  String? get error => _error;

  Ride? get activeRide {
    for (final r in _rides) {
      if (r.isPending || r.isActive) return r;
    }
    return null;
  }

  Future<void> loadRides() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _rides = await _rideService.myRides();
    } catch (e) {
      _error = 'Failed to load rides';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createRide({
    required String pickup,
    required String dropoff,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) async {
    final res = await _rideService.createRide(
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
    );
    if (res.success) {
      await loadRides();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> cancelRide(int id) async {
    final res = await _rideService.cancelRide(id);
    if (res.success) {
      await loadRides();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> rateRide(int id, int score, String? comment) async {
    final res = await _rideService.rateRide(
      id: id,
      score: score,
      comment: comment,
    );
    if (res.success) {
      await loadRides();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }
}
