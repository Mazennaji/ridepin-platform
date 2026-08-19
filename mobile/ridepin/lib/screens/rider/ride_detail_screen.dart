import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _paying = false;

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
      if (mounted) {
        setState(() {
          _ride = r;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool get _needsPayment {
    final r = _ride;
    if (r == null) return false;
    return r.isCompleted &&
        r.transaction != null &&
        r.transaction!.paymentStatus != 'paid';
  }

  Future<void> _cancel() async {
    final ok = await context.read<RideProvider>().cancelRide(widget.rideId);
    if (ok) _load();
  }

  Future<void> _payCash() async {
    setState(() => _paying = true);
    final service = context.read<RideService>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await service.payCash(widget.rideId);
    if (!mounted) return;
    setState(() => _paying = false);
    if (ok) {
      _load();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cash payment recorded'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not record payment'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  Future<void> _payCard() async {
    setState(() => _paying = true);
    final service = context.read<RideService>();
    final messenger = ScaffoldMessenger.of(context);
    final url = await service.startCardCheckout(widget.rideId);
    if (!mounted) return;
    setState(() => _paying = false);
    if (url != null) {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Complete payment in the opened tab, then refresh.'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not start card payment'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  Future<void> _submitRating() async {
    setState(() => _rating = true);
    final provider = context.read<RideProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.rateRide(
      widget.rideId,
      _score,
      _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _rating = false);
    if (ok) {
      _load();
      messenger.showSnackBar(
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
      appBar: AppBar(
        title: const Text('Ride details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDim),
            onPressed: _load,
          ),
        ],
      ),
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
          _infoRow('Status', ride.transaction!.paymentStatus.toUpperCase()),
          if (ride.transaction!.paymentStatus == 'paid')
            _infoRow('Reference', ride.transaction!.transactionReference),
        ],
        const SizedBox(height: 24),
        if (ride.isPending)
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
        if (_needsPayment) _paymentBlock(ride),
        if (ride.canBeRated) _ratingBlock(),
        if (ride.isCompleted && ride.rating != null)
          _ratedSummary(ride.rating!.score, ride.rating!.comment),
      ],
    );
  }

  Widget _paymentBlock(Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.signal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment due',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pay \$${ride.fare.toStringAsFixed(2)} for this trip.',
            style: const TextStyle(color: AppColors.textDim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_paying)
            const Center(
              child: CircularProgressIndicator(color: AppColors.signal),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _payCash,
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _payCard,
                    icon: const Icon(Icons.credit_card, size: 18),
                    label: const Text('Card'),
                  ),
                ),
              ],
            ),
        ],
      ),
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
            'YOUR RATING',
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
