import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/ride_service.dart';
import 'services/driver_service.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/driver_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/rider/rider_home.dart';
import 'screens/driver/driver_home.dart';

void main() {
  final storage = TokenStorage();
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);
  final rideService = RideService(apiClient);
  final driverService = DriverService(apiClient);

  runApp(
    RidePinApp(
      storage: storage,
      authService: authService,
      rideService: rideService,
      driverService: driverService,
    ),
  );
}

class RidePinApp extends StatelessWidget {
  final TokenStorage storage;
  final AuthService authService;
  final RideService rideService;
  final DriverService driverService;

  const RidePinApp({
    super.key,
    required this.storage,
    required this.authService,
    required this.rideService,
    required this.driverService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<RideService>.value(value: rideService),
        Provider<DriverService>.value(value: driverService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storage)..bootstrap(),
        ),
        ChangeNotifierProvider(create: (_) => RideProvider(rideService)),
        ChangeNotifierProvider(create: (_) => DriverProvider(driverService)),
      ],
      child: MaterialApp(
        title: 'RidePin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const _Splash();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        if (auth.isDriver) return const DriverHome();
        return const RiderHome();
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.signal)),
    );
  }
}
