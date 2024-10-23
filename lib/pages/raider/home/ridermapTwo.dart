import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/raider/home/deliveryList.dart';

class RidermapTwo extends StatefulWidget {
  const RidermapTwo({super.key});

  @override
  State<RidermapTwo> createState() => _RidermapTwoState();
}

class _RidermapTwoState extends State<RidermapTwo> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {}; // Changed to final
  final Set<Polyline> polylines = {}; // Changed to final
  LatLng? senderLocation, receiverLocation, currentLocation;
  bool isLoading = true;
  bool isAtSender = false;
  bool isAtReceiver = false;
  late Stream<Position> positionStream;
  late StreamSubscription<Position> positionSubscription;
  late Future<OrdersGetData> orderData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? orderId;
  bool _dialogShown = false;

  final String googleMapsApiKey = 'AIzaSyCAcu7KNBNl-YiZ9YsZiZ6jpQQYmdXwjYU';

  final mapStyle = '''[
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}, {"lightness": 17}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#f5f5f5"}, {"lightness": 20}]},
    {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#ffffff"}, {"lightness": 17}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#ffffff"}, {"lightness": 29}, {"weight": 0.2}]},
    {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}, {"lightness": 19}]}
  ]''';

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments?.toString();
    if (orderId == null) {
      Get.snackbar('Error', 'Order ID is required');
      return;
    }
    orderData = fetchOrderData(int.parse(orderId!));
    _initializeLocations();
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (senderLocation == null || receiverLocation == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ไม่สามารถโหลดตำแหน่งได้',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        _initializeLocations();
                      },
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              )
            else
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: senderLocation ??
                      const LatLng(13.7563, 100.5018), // Default to Bangkok
                  zoom: 14,
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  controller.setMapStyle(mapStyle);
                  _updateCameraPosition();
                },
                markers: markers,
                polylines: polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onTap: (_) => _dialogShown =
                    false, // Reset dialog flag when map is tapped
              ),

            // Status indicator
            if (!isLoading &&
                senderLocation != null &&
                receiverLocation != null)
              FutureBuilder<OrdersGetData>(
                  future: orderData,
                  builder: (BuildContext context, orderSnapshot) {
                    if (!orderSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final order_detail = orderSnapshot.data!;
                    return DraggableScrollableSheet(
                        initialChildSize: 0.3,
                        minChildSize: 0.3,
                        maxChildSize: 0.8,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1D1D1F),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(45)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 138,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'เลขพัสดุ ${order_detail.order_id}',
                                          style: const TextStyle(
                                            fontFamily: 'SukhumvitSet',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7B7B7C),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order_detail
                                                .status), // เรียกใช้ฟังก์ชันเพื่อรับสีตามสถานะ
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(45)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Center(
                                              child: Text(
                                                _getStatusMessage(order_detail
                                                    .status), // เรียกใช้ฟังก์ชันเพื่อรับข้อความตามสถานะ
                                                style: const TextStyle(
                                                  fontFamily: 'SukhumvitSet',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Text(
                                    //   'สถานะ: ${isAtSender ? "ถึงจุดรับสินค้า" : isAtReceiver ? "ถึงจุดส่งสินค้า" : "กำลังเดินทาง"}',
                                    //   style: const TextStyle(
                                    //       fontWeight: FontWeight.bold),
                                    // ),
                                    if (currentLocation != null &&
                                        !isAtReceiver)
                                      Text(
                                        'ระยะทางถึงจุด${isAtSender ? "ส่ง" : "รับ"}: ${Geolocator.distanceBetween(
                                          currentLocation!.latitude,
                                          currentLocation!.longitude,
                                          isAtSender
                                              ? receiverLocation!.latitude
                                              : senderLocation!.latitude,
                                          isAtSender
                                              ? receiverLocation!.longitude
                                              : senderLocation!.longitude,
                                        ).toStringAsFixed(0)} เมตร',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }),
            Positioned(
              top: 50,
              left: 10,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Get.to(() => const Deliverylist()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(int status) {
    switch (status) {
      case 0:
        return 'รอไรเดอร์รับงาน';
      case 1:
        return 'กำลังไปรับสินค้า';
      case 2:
        return 'กำลังส่งสินค้า';
      case 3:
        return 'ส่งสินค้าเสร็จสิ้น';
      default:
        return 'สถานะไม่รู้จัก';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xFFF92A47);
      case 1:
        return const Color(0xFF43474E);
      case 2:
        return const Color(0xFF43474E);
      case 3:
        return const Color(0xFF009A19);
      default:
        return const Color(0xFF808080);
    }
  }

  Future<void> _initializeLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied');
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    try {
      Position initialPosition = await Geolocator.getCurrentPosition();
      _updateRiderLocation(initialPosition);

      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .distinct();
      positionSubscription = positionStream.listen(
        _updateRiderLocation,
        onError: (error) {
          print('Error getting location updates: $error');
          Get.snackbar('Error', 'Failed to get location updates');
        },
      );
    } catch (e) {
      print('Error initializing location tracking: $e');
      Get.snackbar('Error', 'Failed to initialize location tracking');
    }
  }

  Future<void> _updateRiderLocation(Position position) async {
    if (!mounted) return; // Added mounted check

    if (currentLocation != null) {
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < 0) return; // Ignore small movements
    }
    final ByteData data = await rootBundle
        .load('assets/icon/motorcycle.png'); // เปลี่ยนชื่อไฟล์ให้ตรง
    final Uint8List bytes = data.buffer.asUint8List();
    final BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(bytes);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      markers.removeWhere((marker) => marker.markerId.value == 'rider');
      markers.add(Marker(
        markerId: const MarkerId('rider'),
        position: currentLocation!,
        icon: customIcon,
        infoWindow: const InfoWindow(title: 'ตำแหน่งของคุณ'),
      ));
    });

    try {
      _checkDeliveryStatus();
      await _updateFirestoreLocation(position);
    } catch (e) {
      print('Error in location update process: $e');
    }
  }

  Future<void> _updateFirestoreLocation(Position position) async {
    GetStorage gs = GetStorage();
    int uid = gs.read('uid');
    if (!mounted || orderId == null) return; // Added mounted check

    try {
      await _firestore.collection('rider_locations').doc(orderId).set({
        'riderId': 'RIDER_ID',
        'orderId': orderId,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'isAtSender': isAtSender,
        'isAtReceiver': isAtReceiver,
        'speed': position.speed,
        'heading': position.heading,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating Firestore: $e');
      // Don't show error to user as this is not critical
    }
  }

  void _checkDeliveryStatus() {
    if (!mounted ||
        currentLocation == null ||
        senderLocation == null ||
        receiverLocation == null) return;

    double distanceToSender = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      senderLocation!.latitude,
      senderLocation!.longitude,
    );

    double distanceToReceiver = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      receiverLocation!.latitude,
      receiverLocation!.longitude,
    );

    bool wasAtSender = isAtSender;
    bool wasAtReceiver = isAtReceiver;

    setState(() {
      isAtSender = distanceToSender <= 50;
      isAtReceiver = distanceToReceiver <= 50;
    });

    if (!_dialogShown) {
      if (isAtSender && !wasAtSender) {
        _dialogShown = true;
        _showDestinationReachedDialog('คุณมาถึงจุดรับสินค้าแล้ว');
      } else if (isAtReceiver && !wasAtReceiver) {
        _dialogShown = true;
        _showDestinationReachedDialog('คุณมาถึงจุดส่งสินค้าแล้ว');
      }
    }
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    try {
      final response = await http
          .get(Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${start.latitude},${start.longitude}'
            '&destination=${end.latitude},${end.longitude}'
            '&key=$googleMapsApiKey',
          ))
          .timeout(const Duration(seconds: 10)); // Added timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          List<LatLng> route = [];
          for (var step in data['routes'][0]['legs'][0]['steps']) {
            final String polyline = step['polyline']['points'];
            route.addAll(_decodePoly(polyline)); // Changed to private method
          }
          return route;
        }
        throw Exception('Route not found: ${data['status']}');
      }
      throw Exception('Failed to load directions: ${response.statusCode}');
    } catch (e) {
      print('Error fetching route: $e');
      // Return direct line if route fetching fails
      return [start, end];
    }
  }

  List<LatLng> _decodePoly(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _showDestinationReachedDialog(String message) {
    if (!mounted) return;

    Get.snackbar(
      'แจ้งเตือน',
      message,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      onTap: (_) => _dialogShown = false, // Reset dialog flag when tapped
    );
  }

  Future<OrdersGetData> fetchOrderData(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/rider/orders/$orderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      ).timeout(const Duration(seconds: 10)); // Added timeout

      if (response.statusCode == 200) {
        return OrdersGetData.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load order data: ${response.statusCode}');
    } catch (e) {
      print('Error fetching order data: $e');
      rethrow; // Rethrow to handle in _initializeLocations
    }
  }

  void _updateCameraPosition() {
    if (!mounted || mapController == null) return;

    try {
      List<LatLng> points = [];
      if (senderLocation != null) points.add(senderLocation!);
      if (receiverLocation != null) points.add(receiverLocation!);
      if (currentLocation != null) points.add(currentLocation!);

      if (points.isEmpty) return;

      double minLat = points.map((p) => p.latitude).reduce(min);
      double maxLat = points.map((p) => p.latitude).reduce(max);
      double minLng = points.map((p) => p.longitude).reduce(min);
      double maxLng = points.map((p) => p.longitude).reduce(max);

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
    } catch (e) {
      print('Error updating camera position: $e');
    }
  }

  Future<void> _initializeLocations() async {
    if (!mounted) return;

    try {
      final orders = await orderData;

      List<Location> senderLocations =
          await locationFromAddress(orders.sender_address);
      if (senderLocations.isNotEmpty) {
        senderLocation = LatLng(
          senderLocations.first.latitude,
          senderLocations.first.longitude,
        );
      }

      List<Location> receiverLocations =
          await locationFromAddress(orders.receiver_address);
      if (receiverLocations.isNotEmpty) {
        receiverLocation = LatLng(
          receiverLocations.first.latitude,
          receiverLocations.first.longitude,
        );
      }

      if (mounted) {
        setState(() {
          if (senderLocation != null) {
            markers.add(Marker(
              markerId: const MarkerId('sender'),
              position: senderLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: 'จุดรับสินค้า',
                snippet: orders.sender_address,
              ),
            ));
          }

          if (receiverLocation != null) {
            markers.add(Marker(
              markerId: const MarkerId('receiver'),
              position: receiverLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: 'จุดส่งสินค้า',
                snippet: orders.receiver_address,
              ),
            ));
          }

          isLoading = false;
        });

        // Update camera position after markers are added
        if (mapController != null) {
          _updateCameraPosition();
        }
      }
    } catch (e) {
      print('Error initializing locations: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to initialize locations. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
