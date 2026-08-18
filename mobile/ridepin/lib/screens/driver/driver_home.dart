import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/brand.dart';
import '../../widgets/route_line.dart';
import 'active_ride_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>()
        ..syncAvailability()
        ..loadAvailable();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final driver = context.watch<DriverProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const BrandMark(size: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textDim),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.signal,
        backgroundColor: AppColors.surface,
        onRefresh: () => context.read<DriverProvider>().loadAvailable(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              'Hi ${auth.user?.name.split(' ').first ?? ''}',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 20),
            _AvailabilityCard(
              isAvailable: driver.isAvailable,
              onToggle: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                final provider = context.read<DriverProvider>();
                final ok = await provider.toggleAvailability(v);
                if (!ok) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Could not update availability'),
                      backgroundColor: AppColors.surfaceAlt,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AVAILABLE RIDES',
                  style: TextStyle(
                    color: AppColors.textFaint,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                if (driver.available.isNotEmpty)
                  Text(
                    '${driver.available.length}',
                    style: const TextStyle(
                      color: AppColors.signal,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (driver.loading && driver.available.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.signal),
                ),
              )
            else if (!driver.isAvailable)
              const _Hint('Go online to see ride requests near you.')
            else if (driver.available.isEmpty)
              const _Hint('No requests right now. Pull to refresh.')
            else
              ...driver.available.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequestCard(ride: r, onAccept: () => _accept(r)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(Ride ride) async {
    final driver = context.read<DriverProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await driver.accept(ride.id);
    if (!mounted) return;
    if (ok) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const ActiveRideScreen()),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(driver.error ?? 'Could not accept ride'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }
}

class _AvailabilityCard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;
  const _AvailabilityCard({required this.isAvailable, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.signal : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? AppColors.signal : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFF1A1206)
                  : AppColors.textFaint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? "You're online" : "You're offline",
                  style: TextStyle(
                    color: isAvailable
                        ? const Color(0xFF1A1206)
                        : AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? 'Receiving ride requests'
                      : 'Not receiving requests',
                  style: TextStyle(
                    color: isAvailable
                        ? const Color(0xCC1A1206)
                        : AppColors.textDim,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: onToggle,
            activeThumbColor: const Color(0xFF1A1206),
            activeTrackColor: const Color(0x551A1206),
            inactiveThumbColor: AppColors.textDim,
            inactiveTrackColor: AppColors.surfaceAlt,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onAccept;
  const _RequestCard({required this.ride, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.textDim),
                  const SizedBox(width: 6),
                  Text(
                    ride.rider?.name ?? 'Rider',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${ride.fare.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RouteLine(pickup: ride.pickupLocation, dropoff: ride.dropoffLocation),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Accept ride'),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textDim, fontSize: 14),
      ),
    );
  }
}
