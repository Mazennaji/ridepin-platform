import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ride_provider.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final rides = context.read<RideProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await rides.createRide(
      pickup: _pickup.text.trim(),
      dropoff: _dropoff.text.trim(),
      pickupLat: 33.8339,
      pickupLng: 35.5442,
      dropoffLat: 33.8938,
      dropoffLng: 35.5018,
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
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
                                height: 52,
                                color: AppColors.line,
                              ),
                              const Icon(
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
                                  style: const TextStyle(color: AppColors.text),
                                  decoration: const InputDecoration(
                                    hintText: 'Pickup location',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Enter a pickup'
                                      : null,
                                ),
                                const Divider(
                                  color: AppColors.line,
                                  height: 24,
                                ),
                                TextFormField(
                                  controller: _dropoff,
                                  style: const TextStyle(color: AppColors.text),
                                  decoration: const InputDecoration(
                                    hintText: 'Drop-off location',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.textDim,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fare is calculated from trip distance once your ride is booked.',
                              style: TextStyle(
                                color: AppColors.textDim,
                                fontSize: 13,
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
                          : const Text('Confirm booking'),
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
