class RideTransaction {
  final int id;
  final int rideId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionReference;
  final String? paidAt;

  RideTransaction({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionReference,
    this.paidAt,
  });

  factory RideTransaction.fromJson(Map<String, dynamic> json) {
    return RideTransaction(
      id: json['id'] as int,
      rideId: json['ride_id'] as int,
      userId: json['user_id'] as int,
      amount: _toDouble(json['amount']),
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      transactionReference: json['transaction_reference'] as String? ?? '',
      paidAt: json['paid_at'] as String?,
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
