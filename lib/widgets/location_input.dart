import 'package:flutter/material.dart';
// import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';

import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  const LocationInput(this.onSelectPlace, {super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  // // Below method by using "Location" plugin is not working on simulator. So I use "Geolocator" plugin instead.
  // Future<void> _determinePosition() async {
  //   try {
  //     final locData = await Location().getLocation();
  //     final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
  //         latitude: locData.latitude!, longitude: locData.longitude!);
  //     setState(() {
  //       _previewImageUrl = staticMapImageUrl;
  //     });
  //     widget.onSelectPlace(locData.latitude, locData.longitude);
  //   } catch (err) {
  //     return;
  //   }
  // }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      final locData = await Geolocator.getCurrentPosition();
      final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
          latitude: locData.latitude, longitude: locData.longitude);
      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
      widget.onSelectPlace(locData.latitude, locData.longitude);
    } catch (err) {
      return;
    }
  }

  Future<void> _selectOnMap() async {
    // Use async function because we want to get back some data when the MapScreen is popped.
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    try {
      final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude);
      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
      widget.onSelectPlace(
          selectedLocation.latitude, selectedLocation.longitude);
    } catch (err) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? const Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _determinePosition,
              icon: const Icon(Icons.location_on),
              label: const Text('Current Location'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        // Text('Lat: $lat'),
        // Text('Long: $long'),
      ],
    );
  }
}
