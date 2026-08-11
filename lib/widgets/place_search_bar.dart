import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class PlaceSearchBar extends StatelessWidget {
  final void Function(LatLng location, String description) onPlaceSelected;

  const PlaceSearchBar({super.key, required this.onPlaceSelected});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
    assert(googleApiKey != null && googleApiKey.isNotEmpty,
        'Missing GOOGLE_API_KEY in .env');

    return GooglePlaceAutoCompleteTextField(
      textEditingController: searchController,
      googleAPIKey: googleApiKey ?? '',
      inputDecoration: InputDecoration(
        hintText: "Search address",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      debounceTime: 600,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) {
        final lat = double.parse(prediction.lat!);
        final lng = double.parse(prediction.lng!);
        onPlaceSelected(LatLng(lat, lng), prediction.description ?? '');
      },
      itemClick: (prediction) {
        searchController.text = prediction.description ?? '';
      },
    );
  }
}
