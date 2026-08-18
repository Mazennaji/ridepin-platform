import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride.dart';
import '../../services/ride_service.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/route_line.dart';
import '../../widgets/status_pill.dart';

class RideDetailScreen extends StatefulWidget {
  final int rideId;
  const RideDetailScreen({super.key, required this.rideId});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  Ride? _ride;
  bool _loading = true;
  int _score = 5;
  final _comment = TextEditingController();
  bool _rating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final service = context.read<RideService>();
    try {
      final r = await service.getRide(widget.rideId);
      if (mounted)
        setState(() {
          _ride = r;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final ok = await context.read<RideProvider>().cancelRide(widget.rideId);
    if (ok) _load();
  }

  Future<void> _submitRating() async {
    setState(() => _rating = true);
    final ok = await context.read<RideProvider>().rateRide(
      widget.rideId,
      _score,
      _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _rating = false);
    if (ok) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks for the rating'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride details')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.signal),
            )
          : _ride == null
          ? const Center(
              child: Text(
                'Ride not found',
                style: TextStyle(color: AppColors.textDim),
              ),
            )
          : _content(_ride!),
    );
  }

  Widget _content(Ride ride) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatusPill(status: ride.status),
            Text(
              '\$${ride.fare.toStringAsFixed(2)}',
              style: const TextStyle(
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
          child: RouteLine(
            pickup: ride.pickupLocation,
            dropoff: ride.dropoffLocation,
          ),
        ),
        const SizedBox(height: 16),
        if (ride.driver != null) _infoRow('Driver', ride.driver!.name),
        _infoRow('Distance', '${ride.distance.toStringAsFixed(1)} km'),
        if (ride.transaction != null) ...[
          _infoRow('Payment', ride.transaction!.paymentMethod.toUpperCase()),
          _infoRow('Reference', ride.transaction!.transactionReference),
        ],
        const SizedBox(height: 24),
        if (ride.isPending) ...[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _cancel,
            child: const Text(
              'Cancel ride',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        if (ride.canBeRated) _ratingBlock(),
        if (ride.isCompleted && ride.rating != null)
          _ratedSummary(ride.rating!.score, ride.rating!.comment),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDim)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBlock() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate your driver',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(5, (i) {
              final n = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _score = n),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    n <= _score
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.signal,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _comment,
            style: const TextStyle(color: AppColors.text),
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _rating ? null : _submitRating,
            child: _rating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xFF1A1206),
                    ),
                  )
                : const Text('Submit rating'),
          ),
        ],
      ),
    );
  }

  Widget _ratedSummary(int score, String? comment) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your rating',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.signal,
                size: 24,
              ),
            ),
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment, style: const TextStyle(color: AppColors.text)),
          ],
        ],
      ),
    );
  }
}
