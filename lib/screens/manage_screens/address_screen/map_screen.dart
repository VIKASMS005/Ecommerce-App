import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/widgets/place_search_bar.dart';

class MapScreen extends StatefulWidget {
  final GeoPoint? initialLocation;
  final bool isSelecting;
  const MapScreen({
    super.key,
    this.initialLocation = const GeoPoint(12.9716, 77.5946),
    this.isSelecting = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed:
                  _pickedLocation == null
                      ? null
                      : () {
                        Navigator.of(context).pop(_pickedLocation);
                      },
              icon: Icon(Icons.check),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialLocation!.latitude,
                widget.initialLocation!.longitude,
              ),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: widget.isSelecting ? _selectLocation : null,
            markers:
                _pickedLocation == null
                    ? {}
                    : {
                      Marker(
                        markerId: MarkerId('m1'),
                        position: _pickedLocation!,
                      ),
                    },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: PlaceSearchBar(
              onPlaceSelected: (location, description) {
                _selectLocation(location);
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(location, 14),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
