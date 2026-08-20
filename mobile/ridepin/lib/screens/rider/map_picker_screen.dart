import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';

class PickedLocations {
  final LatLng pickup;
  final LatLng dropoff;
  const PickedLocations({required this.pickup, required this.dropoff});
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _initial = LatLng(33.8886, 35.4955);

  LatLng? _pickup;
  LatLng? _dropoff;

  void _onTap(LatLng pos) {
    setState(() {
      if (_pickup == null) {
        _pickup = pos;
      } else if (_dropoff == null) {
        _dropoff = pos;
      } else {
        _pickup = pos;
        _dropoff = null;
      }
    });
  }

  void _reset() => setState(() {
    _pickup = null;
    _dropoff = null;
  });

  Set<Marker> get _markers {
    final m = <Marker>{};
    if (_pickup != null) {
      m.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
      );
    }
    if (_dropoff != null) {
      m.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoff!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Drop-off'),
        ),
      );
    }
    return m;
  }

  Set<Polyline> get _lines {
    if (_pickup != null && _dropoff != null) {
      return {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickup!, _dropoff!],
          color: AppColors.signal,
          width: 4,
        ),
      };
    }
    return {};
  }

  String get _hint {
    if (_pickup == null) return 'Tap the map to set your pickup';
    if (_dropoff == null) return 'Now tap to set your destination';
    return 'Looks good — confirm below or reset';
  }

  String _fmt(LatLng? p) => p == null
      ? 'Not set'
      : '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick locations'),
        actions: [
          if (_pickup != null || _dropoff != null)
            TextButton(onPressed: _reset, child: const Text('Reset')),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initial,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _lines,
            onTap: _onTap,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Hint pill
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, size: 18, color: AppColors.signal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _hint,
                      style: TextStyle(color: AppColors.text, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom summary sheet
          if (_pickup != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                              height: 30,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PICKUP',
                                style: TextStyle(
                                  color: AppColors.textFaint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                _fmt(_pickup),
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'DROP-OFF',
                                style: TextStyle(
                                  color: AppColors.textFaint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                _fmt(_dropoff),
                                style: TextStyle(
                                  color: _dropoff == null
                                      ? AppColors.textFaint
                                      : AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_pickup != null && _dropoff != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFC44D), AppColors.signal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.signal.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(
                              PickedLocations(
                                pickup: _pickup!,
                                dropoff: _dropoff!,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: const Text(
                                'Use these locations',
                                style: TextStyle(
                                  color: Color(0xFF1A1206),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 54,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Tap to set your destination',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
