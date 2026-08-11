import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopping_app/screens/manage_screens/address_screen/map_screen.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationInput extends StatefulWidget {
  final void Function(GeoPoint location) onSelectLocation;
  final GeoPoint? initialLocation;
  final void Function({
    required String area,
    required String city,
    required String state,
    required String pincode,
  })
  onAddressResolved;
  const LocationInput({
    super.key,
    required this.onSelectLocation,
    this.initialLocation,
    required this.onAddressResolved,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  late LatLng _selectedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation != null
            ? LatLng(
              widget.initialLocation!.latitude,
              widget.initialLocation!.longitude,
            )
            : const LatLng(12.9716, 77.5946);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        widget.onAddressResolved(
          area: place.subLocality ?? place.street ?? '',
          city: place.locality ?? '',
          state: place.administrativeArea ?? '',
          pincode: place.postalCode ?? '',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch address for this location'),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locData = await Location().getLocation();

      final newLocation = LatLng(locData.latitude, locData.longitude);

      setState(() {
        _selectedLocation = newLocation;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 14),
      );
      widget.onSelectLocation(
        GeoPoint(newLocation.latitude, newLocation.longitude),
      );
      _reverseGeocode(newLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied or unavailable'),
          ),
        );
      }
    }
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MapScreen(isSelecting: true),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    final LatLng picked = selectedLocation;

    setState(() {
      _selectedLocation = picked;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(picked, 14));

    widget.onSelectLocation(GeoPoint(picked.latitude, picked.longitude));
    _reverseGeocode(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation,
              ),
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                _getCurrentLocation();
              },
              label: Text(
                'Current Location',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              icon: Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _selectOnMap();
              },
              label: Text(
                'Select on Map',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              icon: Icon(Icons.map, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ],
    );
  }
}
