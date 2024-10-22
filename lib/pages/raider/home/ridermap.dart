import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Ridermap extends StatefulWidget {
  const Ridermap({super.key});

  @override
    State<Ridermap> createState() => _RidermapState();
}

class _RidermapState extends State<Ridermap> {
  LatLng latLng = const LatLng(15.985355076669551, 102.6208824793564);
  MapController mapController = MapController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            FilledButton(
              onPressed: () async {
                try {
                  var position = await _determinePosition();
                  setState(() {
                      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
                    latLng = LatLng(position.latitude, position.longitude);
                    errorMessage = '';
                  });
                  mapController.move(latLng, mapController.camera.zoom);
                } catch (e) {
                  setState(() {
                    errorMessage = 'Error: $e';
                  });
                }
              },
              child: const Text('Get location!'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: latLng,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.motorcycle,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}
