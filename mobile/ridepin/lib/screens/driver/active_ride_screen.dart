import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/route_line.dart';
import '../../widgets/status_pill.dart';

class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final ride = driver.activeRide;

    return Scaffold(
      appBar: AppBar(title: const Text('Active ride')),
      body: ride == null
          ? Center(
              child: Text(
                'No active ride',
                style: TextStyle(color: AppColors.textDim),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(status: ride.status),
                    Text(
                      '\$${ride.fare.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.textDim,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ride.rider?.name ?? 'Rider',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.line, height: 28),
                      RouteLine(
                        pickup: ride.pickupLocation,
                        dropoff: ride.dropoffLocation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _StepTimeline(status: ride.status),
                const SizedBox(height: 24),
                if (ride.transaction != null) _TransactionCard(ride: ride),
                const SizedBox(height: 16),
                _ActionButton(ride: ride),
              ],
            ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Ride ride;
  const _ActionButton({required this.ride});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() => _busy = true);
    final driver = context.read<DriverProvider>();
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driver.error ?? 'Action failed'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final driver = context.read<DriverProvider>();

    if (ride.isCompleted) {
      return ElevatedButton(
        onPressed: () {
          driver.clearActive();
          Navigator.of(context).pop();
        },
        child: const Text('Done'),
      );
    }

    final (label, onPressed) = switch (ride.status) {
      RideStatus.accepted => (
        'Start ride',
        () => _run(() => driver.start(ride.id)),
      ),
      RideStatus.started => (
        'Complete ride',
        () => _run(() => driver.complete(ride.id)),
      ),
      _ => ('Waiting', null),
    };

    return ElevatedButton(
      onPressed: _busy ? null : onPressed,
      child: _busy
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF1A1206),
              ),
            )
          : Text(label),
    );
  }
}

class _StepTimeline extends StatelessWidget {
  final String status;
  const _StepTimeline({required this.status});

  int get _stage => switch (status) {
    RideStatus.accepted => 0,
    RideStatus.started => 1,
    RideStatus.completed => 2,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    const steps = ['Accepted', 'In progress', 'Completed'];
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i <= _stage;
        final isLast = i == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: done ? AppColors.signal : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.signal : AppColors.line,
                        width: 2,
                      ),
                    ),
                    child: done
                        ? const Icon(
                            Icons.check,
                            size: 15,
                            color: Color(0xFF1A1206),
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i],
                    style: TextStyle(
                      color: done ? AppColors.text : AppColors.textFaint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 22),
                    color: i < _stage ? AppColors.signal : AppColors.line,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Ride ride;
  const _TransactionCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final t = ride.transaction!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment received',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '\$${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${t.paymentMethod.toUpperCase()}  ·  ${t.transactionReference}',
            style: TextStyle(color: AppColors.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
