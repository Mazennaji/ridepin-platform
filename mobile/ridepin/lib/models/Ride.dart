import 'user.dart';
import 'transaction.dart';
import 'rating.dart';

class RideStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const started = 'started';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

class Ride {
  final int id;
  final int riderId;
  final int? driverId;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double fare;
  final double distance;
  final String status;
  final String? createdAt;

  final AppUser? rider;
  final AppUser? driver;
  final RideTransaction? transaction;
  final Rating? rating;

  Ride({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    required this.fare,
    required this.distance,
    required this.status,
    this.createdAt,
    this.rider,
    this.driver,
    this.transaction,
    this.rating,
  });

  bool get isPending => status == RideStatus.pending;
  bool get isAccepted => status == RideStatus.accepted;
  bool get isStarted => status == RideStatus.started;
  bool get isCompleted => status == RideStatus.completed;
  bool get isCancelled => status == RideStatus.cancelled;
  bool get isActive => isAccepted || isStarted;
  bool get canBeRated => isCompleted && rating == null;

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as int,
      riderId: json['rider_id'] as int,
      driverId: json['driver_id'] as int?,
      pickupLocation: json['pickup_location'] as String? ?? '',
      dropoffLocation: json['dropoff_location'] as String? ?? '',
      pickupLat: _toDoubleN(json['pickup_latitude']),
      pickupLng: _toDoubleN(json['pickup_longitude']),
      dropoffLat: _toDoubleN(json['dropoff_latitude']),
      dropoffLng: _toDoubleN(json['dropoff_longitude']),
      fare: _toDouble(json['fare']),
      distance: _toDouble(json['distance']),
      status: json['status'] as String? ?? RideStatus.pending,
      createdAt: json['created_at'] as String?,
      rider: json['rider'] is Map
          ? AppUser.fromJson(Map<String, dynamic>.from(json['rider']))
          : null,
      driver: json['driver'] is Map
          ? AppUser.fromJson(Map<String, dynamic>.from(json['driver']))
          : null,
      transaction: json['transaction'] is Map
          ? RideTransaction.fromJson(
              Map<String, dynamic>.from(json['transaction']),
            )
          : null,
      rating: json['rating'] is Map
          ? Rating.fromJson(Map<String, dynamic>.from(json['rating']))
          : null,
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

double? _toDoubleN(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
