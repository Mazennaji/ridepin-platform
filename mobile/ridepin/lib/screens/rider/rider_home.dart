import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/brand.dart';
import '../profile/profile_screen.dart';
import '../../widgets/route_line.dart';
import '../../widgets/status_pill.dart';
import 'request_ride_screen.dart';
import 'ride_detail_screen.dart';

class RiderHome extends StatefulWidget {
  const RiderHome({super.key});

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rides = context.watch<RideProvider>();
    final active = rides.activeRide;
    final history = rides.rides
        .where((r) => r.isCompleted || r.isCancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const BrandMark(size: 30),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.textDim),
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
        onRefresh: () => context.read<RideProvider>().loadRides(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Text(
              'Hi ${auth.user?.name.split(' ').first ?? ''}',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Where are you headed?',
              style: TextStyle(color: AppColors.textDim, fontSize: 15),
            ),
            const SizedBox(height: 24),
            if (active != null) ...[
              const _SectionLabel('Current ride'),
              const SizedBox(height: 12),
              _RideCard(ride: active, onTap: () => _openDetail(active)),
              const SizedBox(height: 28),
            ],
            const _SectionLabel('History'),
            const SizedBox(height: 12),
            if (rides.loading && rides.rides.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.signal),
                ),
              )
            else if (history.isEmpty)
              _Empty(active == null)
            else
              ...history.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RideCard(ride: r, onTap: () => _openDetail(r)),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: active == null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.signal,
              foregroundColor: const Color(0xFF1A1206),
              icon: const Icon(Icons.add),
              label: const Text(
                'Book a ride',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _openRequest,
            )
          : null,
    );
  }

  Future<void> _openRequest() async {
    final rides = context.read<RideProvider>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RequestRideScreen()));
    rides.loadRides();
  }

  Future<void> _openDetail(Ride ride) async {
    final rides = context.read<RideProvider>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RideDetailScreen(rideId: ride.id)),
    );
    rides.loadRides();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textFaint,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;
  const _RideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    StatusPill(status: ride.status),
                    if (ride.isScheduled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Scheduled',
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            RouteLine(
              pickup: ride.pickupLocation,
              dropoff: ride.dropoffLocation,
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool showHint;
  const _Empty(this.showHint);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(
            Icons.route_outlined,
            color: AppColors.textFaint,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'No rides yet',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            showHint ? 'Book your first ride to get moving.' : '',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
