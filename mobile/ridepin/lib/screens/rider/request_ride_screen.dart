import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ride_provider.dart';
import '../../services/ride_service.dart';
import 'map_picker_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();

  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  FareEstimate? _estimate;
  bool _estimating = false;
  bool _submitting = false;

  bool _scheduleLater = false;
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    final result = await Navigator.of(context).push<PickedLocations>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _pickupLatLng = result.pickup;
      _dropoffLatLng = result.dropoff;
      if (_pickup.text.trim().isEmpty) {
        _pickup.text =
            '${result.pickup.latitude.toStringAsFixed(4)}, ${result.pickup.longitude.toStringAsFixed(4)}';
      }
      if (_dropoff.text.trim().isEmpty) {
        _dropoff.text =
            '${result.dropoff.latitude.toStringAsFixed(4)}, ${result.dropoff.longitude.toStringAsFixed(4)}';
      }
    });
    _fetchEstimate();
  }

  Future<void> _fetchEstimate() async {
    if (_pickupLatLng == null || _dropoffLatLng == null) return;
    setState(() => _estimating = true);
    final service = context.read<RideService>();
    final est = await service.estimate(
      pickupLat: _pickupLatLng!.latitude,
      pickupLng: _pickupLatLng!.longitude,
      dropoffLat: _dropoffLatLng!.latitude,
      dropoffLng: _dropoffLatLng!.longitude,
    );
    if (!mounted) return;
    setState(() {
      _estimate = est;
      _estimating = false;
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickupLatLng == null || _dropoffLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick your locations on the map first'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
      return;
    }
    if (_scheduleLater && _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick a date and time for your scheduled ride'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final rides = context.read<RideProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await rides.createRide(
      pickup: _pickup.text.trim(),
      dropoff: _dropoff.text.trim(),
      pickupLat: _pickupLatLng!.latitude,
      pickupLng: _pickupLatLng!.longitude,
      dropoffLat: _dropoffLatLng!.latitude,
      dropoffLng: _dropoffLatLng!.longitude,
      scheduledAt: _scheduleLater ? _scheduledAt : null,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(rides.error ?? 'Could not book ride'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
    return '$d at $t';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a ride')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _openMap,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _pickupLatLng != null
                                ? AppColors.signal
                                : AppColors.line,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              color: AppColors.signal,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _pickupLatLng == null
                                    ? 'Choose pickup & drop-off on map'
                                    : 'Locations set — tap to change',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textDim,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pickup,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Pickup label',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a pickup'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dropoff,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Drop-off label',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a destination'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (_estimating)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.signal,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Estimating fare…',
                              style: TextStyle(color: AppColors.textDim),
                            ),
                          ],
                        ),
                      )
                    else if (_estimate != null)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.signal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.signal.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estimated fare',
                                  style: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_estimate!.distance.toStringAsFixed(1)} km trip',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${_estimate!.fare.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Schedule for later',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _scheduleLater,
                            activeThumbColor: AppColors.signal,
                            onChanged: (v) => setState(() {
                              _scheduleLater = v;
                              if (!v) _scheduledAt = null;
                            }),
                          ),
                          if (_scheduleLater)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: _pickDateTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 18,
                                        color: AppColors.signal,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _scheduledAt == null
                                            ? 'Pick date & time'
                                            : _formatDateTime(_scheduledAt!),
                                        style: const TextStyle(
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Color(0xFF1A1206),
                              ),
                            )
                          : Text(
                              _scheduleLater
                                  ? 'Schedule ride'
                                  : 'Confirm booking',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
