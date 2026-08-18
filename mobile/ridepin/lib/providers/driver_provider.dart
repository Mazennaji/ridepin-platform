import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/driver_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverService _driverService;
  DriverProvider(this._driverService);

  List<Ride> _available = [];
  Ride? _activeRide;
  bool _isAvailable = false;
  bool _loading = false;
  String? _error;

  List<Ride> get available => _available;
  Ride? get activeRide => _activeRide;
  bool get isAvailable => _isAvailable;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> syncAvailability() async {
    final profile = await _driverService.myProfile();
    if (profile != null) {
      _isAvailable = profile.isAvailable;
      notifyListeners();
    }
  }

  Future<void> loadAvailable() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _available = await _driverService.availableRides();
    } catch (e) {
      _error = 'Failed to load available rides';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> toggleAvailability(bool value) async {
    final ok = await _driverService.toggleAvailability(value);
    if (ok) {
      _isAvailable = value;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> accept(int id) async {
    final res = await _driverService.accept(id);
    if (res.success) {
      _activeRide = res.ride;
      await loadAvailable();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> start(int id) async {
    final res = await _driverService.start(id);
    if (res.success) {
      _activeRide = res.ride;
      notifyListeners();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  Future<bool> complete(int id) async {
    final res = await _driverService.complete(id);
    if (res.success) {
      _activeRide = res.ride;
      notifyListeners();
      return true;
    }
    _error = res.error;
    notifyListeners();
    return false;
  }

  void clearActive() {
    _activeRide = null;
    notifyListeners();
  }
}
