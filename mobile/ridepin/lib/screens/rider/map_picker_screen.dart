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
  static const _initial = LatLng(33.8886, 35.4955); // Beirut

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
    if (_pickup == null) return 'Tap the map to set your pickup point';
    if (_dropoff == null) return 'Now tap to set your destination';
    return 'Tap "Use these" to continue, or tap again to reset';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick locations')),
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
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app,
                    size: 18,
                    color: AppColors.signal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _hint,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_pickup != null && _dropoff != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(PickedLocations(pickup: _pickup!, dropoff: _dropoff!)),
                child: const Text('Use these locations'),
              ),
            ),
        ],
      ),
    );
  }
}
