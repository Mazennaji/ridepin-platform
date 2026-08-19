class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';

  static const String rides = '/rides';
  static const String estimate = '/rides/estimate';
  static String rideById(int id) => '/rides/$id';
  static String cancelRide(int id) => '/rides/$id/cancel';
  static String rateRide(int id) => '/rides/$id/rate';
  static String paymentCheckout(int id) => '/rides/$id/payment/intent';
  static String paymentConfirmCard(int id) => '/rides/$id/payment/card';
  static String paymentCash(int id) => '/rides/$id/payment/cash';

  static const String availableRides = '/driver/rides/available';
  static String acceptRide(int id) => '/driver/rides/$id/accept';
  static String startRide(int id) => '/driver/rides/$id/start';
  static String completeRide(int id) => '/driver/rides/$id/complete';
  static const String toggleAvailability = '/driver/toggle-availability';
}
