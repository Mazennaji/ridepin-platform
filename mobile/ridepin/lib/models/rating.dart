class Rating {
  final int id;
  final int rideId;
  final int riderId;
  final int driverId;
  final int score;
  final String? comment;

  Rating({
    required this.id,
    required this.rideId,
    required this.riderId,
    required this.driverId,
    required this.score,
    this.comment,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as int,
      rideId: json['ride_id'] as int,
      riderId: json['rider_id'] as int,
      driverId: json['driver_id'] as int,
      score: json['score'] as int? ?? 0,
      comment: json['comment'] as String?,
    );
  }
}
