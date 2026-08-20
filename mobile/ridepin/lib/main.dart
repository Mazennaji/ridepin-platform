import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
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
  final themeController = ThemeController()..load();

  runApp(
    RidePinApp(
      storage: storage,
      authService: authService,
      rideService: rideService,
      driverService: driverService,
      themeController: themeController,
    ),
  );
}

class RidePinApp extends StatelessWidget {
  final TokenStorage storage;
  final AuthService authService;
  final RideService rideService;
  final DriverService driverService;
  final ThemeController themeController;

  const RidePinApp({
    super.key,
    required this.storage,
    required this.authService,
    required this.rideService,
    required this.driverService,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        Provider<AuthService>.value(value: authService),
        Provider<RideService>.value(value: rideService),
        Provider<DriverService>.value(value: driverService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storage)..bootstrap(),
        ),
        ChangeNotifierProvider(create: (_) => RideProvider(rideService)),
        ChangeNotifierProvider(create: (_) => DriverProvider(driverService)),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          // Keep the static palette in sync with the active mode so that
          // AppColors.* getters resolve to the correct brightness.
          AppColors.setDark(theme.isDark);
          return MaterialApp(
            title: 'RidePin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            home: const AuthGate(),
          );
        },
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
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.signal)),
    );
  }
}
