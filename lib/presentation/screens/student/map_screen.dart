import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../providers/tutor_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  Position? _userPosition;
  double _radiusKm = AppConstants.defaultRadius;
  Set<Marker> _markers = {};
  TutorEntity? _selectedTutor;
  bool _locationLoading = true;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
    zoom: AppConstants.defaultMapZoom,
  );

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _userPosition = pos;
        _locationLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          AppConstants.defaultMapZoom,
        ),
      );

      _loadNearbyTutors();
    } catch (e) {
      setState(() => _locationLoading = false);
    }
  }

  Future<void> _loadNearbyTutors() async {
    final lat = _userPosition?.latitude ?? AppConstants.defaultLat;
    final lng = _userPosition?.longitude ?? AppConstants.defaultLng;

    final tutors = await ref.read(
      nearbyTutorsProvider((lat: lat, lng: lng, radius: _radiusKm)).future,
    );

    _buildMarkers(tutors);
  }

  void _buildMarkers(List<TutorEntity> tutors) {
    final markers = <Marker>{};

    // User location marker
    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Tutor markers
    for (final tutor in tutors) {
      if (tutor.location == null) continue;
      markers.add(
        Marker(
          markerId: MarkerId(tutor.id),
          position: LatLng(
              tutor.location!.latitude, tutor.location!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: tutor.fullName,
            snippet:
                '${tutor.subjects.take(2).join(', ')} · ★ ${tutor.rating.toStringAsFixed(1)}',
          ),
          onTap: () => setState(() => _selectedTutor = tutor),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Tutors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _getUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _defaultPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _controllerCompleter.complete(controller);
              _mapController = controller;
            },
            onTap: (_) => setState(() => _selectedTutor = null),
          ),

          // Radius slider
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: _RadiusSelector(
              radius: _radiusKm,
              onChanged: (r) {
                setState(() => _radiusKm = r);
                _loadNearbyTutors();
              },
            ),
          ),

          // Loading
          if (_locationLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Selected tutor card
          if (_selectedTutor != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _TutorMapCard(
                tutor: _selectedTutor!,
                onTap: () => context.push('/tutor/${_selectedTutor!.id}'),
                onClose: () => setState(() => _selectedTutor = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadiusSelector extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onChanged;
  const _RadiusSelector({required this.radius, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.radar, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Search radius: ${radius.toStringAsFixed(0)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          Slider(
            value: radius,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TutorMapCard extends StatelessWidget {
  final TutorEntity tutor;
  final VoidCallback onTap;
  final VoidCallback onClose;
  const _TutorMapCard(
      {required this.tutor, required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              child: Text(
                tutor.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tutor.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'Poppins')),
                  Text(
                    tutor.subjects.take(2).join(', '),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey500,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppTheme.warningColor),
                      const SizedBox(width: 2),
                      Text(
                        '${tutor.rating.toStringAsFixed(1)} · ${tutor.totalReviews} reviews',
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
