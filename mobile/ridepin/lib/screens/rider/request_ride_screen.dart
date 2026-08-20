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
        SnackBar(
          content: Text('Pick your locations on the map first'),
          backgroundColor: AppColors.surfaceAlt,
        ),
      );
      return;
    }
    if (_scheduleLater && _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

  bool get _hasLocations => _pickupLatLng != null && _dropoffLatLng != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a ride')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Map picker button
                    GestureDetector(
                      onTap: _openMap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _hasLocations
                                ? AppColors.signal
                                : AppColors.line,
                          ),
                          boxShadow: _hasLocations
                              ? [
                                  BoxShadow(
                                    color: AppColors.signal.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.signal.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                color: AppColors.signal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hasLocations
                                        ? 'Locations set'
                                        : 'Choose on map',
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _hasLocations
                                        ? 'Tap to adjust pickup & drop-off'
                                        : 'Set your pickup & destination',
                                    style: TextStyle(
                                      color: AppColors.textDim,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.textDim),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Route labels card with route-line
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.signal,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 44,
                                color: AppColors.line,
                              ),
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.danger,
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _pickup,
                                  style: TextStyle(color: AppColors.text),
                                  decoration: InputDecoration(
                                    hintText: 'Pickup label',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Enter a pickup'
                                      : null,
                                ),
                                Divider(color: AppColors.line, height: 22),
                                TextFormField(
                                  controller: _dropoff,
                                  style: TextStyle(color: AppColors.text),
                                  decoration: InputDecoration(
                                    hintText: 'Drop-off label',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Enter a destination'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fare estimate
                    if (_estimating)
                      _infoTile(
                        leading: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.signal,
                          ),
                        ),
                        text: 'Estimating fare…',
                      )
                    else if (_estimate != null)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.signal.withValues(alpha: 0.16),
                              AppColors.signal.withValues(alpha: 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.signal.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated fare',
                                  style: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_estimate!.distance.toStringAsFixed(1)} km trip',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${_estimate!.fare.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_estimating || _estimate != null)
                      const SizedBox(height: 16),
                    // Schedule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                              Icons.schedule,
                              color: _scheduleLater
                                  ? AppColors.signal
                                  : AppColors.textDim,
                            ),
                            title: Text(
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
                              padding: const EdgeInsets.only(bottom: 12),
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
                                      Icon(
                                        Icons.event,
                                        size: 18,
                                        color: AppColors.signal,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _scheduledAt == null
                                            ? 'Pick date & time'
                                            : _formatDateTime(_scheduledAt!),
                                        style: TextStyle(color: AppColors.text),
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
                    // Confirm button — gradient + glow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFC44D), AppColors.signal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: _submitting
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.signal.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _submitting ? null : _submit,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
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
                                    style: const TextStyle(
                                      color: Color(0xFF1A1206),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
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

  Widget _infoTile({required Widget leading, required String text}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: AppColors.textDim)),
        ],
      ),
    );
  }
}
