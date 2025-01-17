import 'dart:math';
import 'dart:async';
import 'dart:developer' as dev;
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
import 'package:runtod_app/model/Request/RiderGetJob.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/raider/home/riderHome.dart';
import 'package:runtod_app/pages/raider/home/ridermapTwo.dart';

class RidermapOne extends StatefulWidget {
  const RidermapOne({super.key});

  @override
  State<RidermapOne> createState() => _RidermapOneState();
}

class _RidermapOneState extends State<RidermapOne> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
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
  bool Checkdistance = false;

  bool isNearSender = false;
  bool isNearReceiver = false;
  final double proximityThreshold = 20.0;

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
            // Google Map and other content will go here
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
                  target: senderLocation ?? const LatLng(13.7563, 100.5018),
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
                onTap: (_) => _dialogShown = false,
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
                    initialChildSize: 0.4,
                    minChildSize: 0.4,
                    maxChildSize: 0.8,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D1D1F),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(45)),
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
                                        color: _getStatusColor(
                                            order_detail.status),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(45)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(
                                            _getStatusMessage(
                                                order_detail.status),
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
                                const SizedBox(height: 15),
                                if (currentLocation != null && !isAtReceiver)
                                  Text(
                                    'ระยะทาง ${Geolocator.distanceBetween(
                                      senderLocation!.latitude,
                                      senderLocation!.longitude,
                                      receiverLocation!.latitude,
                                      receiverLocation!.longitude,
                                    ).toStringAsFixed(0)} เมตร',
                                    style: const TextStyle(
                                      fontFamily: 'SukhumvitSet',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'ผู้ส่ง',
                                          style: const TextStyle(
                                            fontFamily: 'SukhumvitSet',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF7B7B7C),
                                          ),
                                        ),
                                        Text(
                                          order_detail.sender_name,
                                          style: const TextStyle(
                                            fontFamily: 'SukhumvitSet',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_rounded, size: 45),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        Text(
                                          'ผู้รับ',
                                          style: const TextStyle(
                                            fontFamily: 'SukhumvitSet',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF7B7B7C),
                                          ),
                                        ),
                                        Text(
                                          order_detail.receiver_name,
                                          style: const TextStyle(
                                            fontFamily: 'SukhumvitSet',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'จำนวน ${order_detail.total_orders} รายการ',
                                  style: const TextStyle(
                                    fontFamily: 'SukhumvitSet',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Get.to(() => const Riderhome()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF9D9797),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: const Text(
                                        'ไม่รับส่งสินค้า',
                                        style: TextStyle(
                                          fontFamily: 'SukhumvitSet',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _GetJob(order_detail.order_id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: const Text(
                                        'รับส่งสินค้า',
                                        style: TextStyle(
                                          fontFamily: 'SukhumvitSet',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            // ปุ่มย้อนกลับจะอยู่ด้านบนสุด
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
                      onPressed: () => Get.to(() => const Riderhome()),
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
    if (!mounted) return;

    if (currentLocation != null) {
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < 0) return;
    }
    final ByteData data = await rootBundle.load('assets/icon/motorcycle.png');
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
    if (!mounted || orderId == null) return;

    try {
      await _firestore.collection('rider_locations').doc(orderId).set({
        'riderId': uid,
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

      if (senderLocation != null && receiverLocation != null) {
        double distanceBetweenPoints = Geolocator.distanceBetween(
          senderLocation!.latitude,
          senderLocation!.longitude,
          receiverLocation!.latitude,
          receiverLocation!.longitude,
        );

        bool isWithinDistance = distanceBetweenPoints <= 20;

        dev.log(
            'ระยะห่างระหว่างจุดรับและจุดส่ง: ${distanceBetweenPoints.toStringAsFixed(2)} เมตร');
        dev.log(
            'อยู่ในระยะ 20 เมตรหรือไม่: ${isWithinDistance ? "ใช่" : "ไม่"}');

        if (isWithinDistance && mounted) {
          Checkdistance = true;
          Get.snackbar(
            'แจ้งเตือน',
            'จุดรับและจุดส่งอยู่ในระยะไม่เกิน 20 เมตร',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
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
                title: 'ผู้ส่ง: ${orders.sender_name}',
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
                title: 'ผู้รับ: ${orders.receiver_name}',
                snippet: orders.receiver_address,
              ),
            ));
          }

          isLoading = false;
        });

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

  Future<void> _GetJob(int orderId) async {
    GetStorage gs = GetStorage();
    int uid = gs.read('uid');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Container(
              height: 370,
              decoration: const BoxDecoration(
                color: Color(0xFF1D1D1F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xFF4A4A4C),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 80),
                  const Text(
                    'ยืนยันรับออเดอร์',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'คุณต้องรับส่งออเดอร์นี้ใช่ไหม?',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6C6C6C),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF6C6C6C),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (Checkdistance = true) {
                            var data = RiderGetJobRequest(
                              uid: uid,
                              order_id: orderId,
                            );
                            var response = await http.put(
                              Uri.parse('$API_ENDPOINT/rider/orders/get-job'),
                              headers: {
                                "Content-Type":
                                    "application/json; charset=utf-8"
                              },
                              body: jsonEncode(data.toJson()),
                            );

                            if (response.statusCode == 200) {
                              GetStorage gs = GetStorage();
                              gs.write('oid', orderId.toString());
                              Get.to(() => const RidermapTwo(),
                                  arguments: orderId);
                              showSnackbar('สำเร็จ!', 'รับส่งสินค้านี้',
                                  backgroundColor: Colors.blue);
                            } else {
                              try {
                                var errorMessage =
                                    jsonDecode(response.body)['error'] ??
                                        'เกิดข้อผิดพลาด';
                                showSnackbar('ไม่สำเร็จ!', errorMessage,
                                    backgroundColor: Colors.red);
                                Navigator.of(context).pop();
                              } catch (e) {
                                showSnackbar('รับออเดอร์ไม่สำเร็จ!',
                                    'เกิดข้อผิดพลาด: ${response.body}',
                                    backgroundColor: Colors.red);
                                Navigator.of(context).pop();
                              }
                            }
                          } else {
                            showSnackbar('รับออเดอร์ไม่สำเร็จ!',
                                'จุดผู้รับ กับ จุดผู้ส่ง ระยะเกิน 20 เมตร',
                                backgroundColor: Colors.red);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'ยืนยัน',
                            style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(String title, String message,
      {Color backgroundColor = Colors.blue}) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'SukhumvitSet',
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: 'SukhumvitSet',
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(30),
      borderRadius: 22,
    );
  }
}
