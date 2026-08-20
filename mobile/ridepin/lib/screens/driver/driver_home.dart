import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/ride_service.dart';
import '../../widgets/brand.dart';
import '../../widgets/route_line.dart';
import '../profile/profile_screen.dart';
import 'active_ride_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  List<Ride> _myRides = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>()
        ..syncAvailability()
        ..loadAvailable();
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    try {
      final rides = await context.read<RideService>().myRides();
      if (mounted) setState(() => _myRides = rides);
    } catch (_) {}
  }

  int get _completed => _myRides.where((r) => r.isCompleted).length;

  double get _earnings => _myRides
      .where((r) => r.transaction?.paymentStatus == 'paid')
      .fold(0.0, (s, r) => s + (r.transaction?.amount ?? 0));

  double? get _rating {
    final rated = _myRides.where((r) => r.rating != null).toList();
    if (rated.isEmpty) return null;
    return rated.fold(0, (s, r) => s + (r.rating?.score ?? 0)) / rated.length;
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
            icon: const Icon(Icons.person_outline, color: AppColors.textDim),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.signal,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await context.read<DriverProvider>().loadAvailable();
          await _loadStats();
        },
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
            const SizedBox(height: 2),
            Text(
              driver.isAvailable
                  ? 'You are online and ready for trips'
                  : 'You are offline',
              style: const TextStyle(color: AppColors.textDim, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _AvailabilityHero(
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
            const SizedBox(height: 16),
            Row(
              children: [
                _stat('Trips', '$_completed', Icons.check_circle_outline),
                const SizedBox(width: 12),
                _stat(
                  'Earnings',
                  '\$${_earnings.toStringAsFixed(0)}',
                  Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(width: 12),
                _stat(
                  'Rating',
                  _rating == null ? '—' : _rating!.toStringAsFixed(1),
                  Icons.star_outline,
                ),
              ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.signal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${driver.available.length} nearby',
                      style: const TextStyle(
                        color: AppColors.signal,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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
              _emptyState(
                Icons.toggle_off_outlined,
                'You are offline',
                'Go online to start receiving ride requests.',
              )
            else if (driver.available.isEmpty)
              _emptyState(
                Icons.radar,
                'Waiting for requests',
                'New ride requests will appear here. Pull to refresh.',
              )
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

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.signal),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textDim, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: 14),
          ),
        ],
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

class _AvailabilityHero extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;
  const _AvailabilityHero({required this.isAvailable, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isAvailable
            ? const LinearGradient(
                colors: [Color(0xFFFFC44D), AppColors.signal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isAvailable ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAvailable ? AppColors.signal : AppColors.line,
        ),
        boxShadow: isAvailable
            ? [
                BoxShadow(
                  color: AppColors.signal.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0x261A1206)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isAvailable ? Icons.bolt : Icons.power_settings_new,
              color: isAvailable ? const Color(0xFF1A1206) : AppColors.textDim,
            ),
          ),
          const SizedBox(width: 16),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable ? 'Receiving ride requests' : 'Tap to go online',
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
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ride.rider?.name ?? 'Rider',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${ride.fare.toStringAsFixed(2)}',
                style: TextStyle(
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
