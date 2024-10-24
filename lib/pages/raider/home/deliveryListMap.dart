import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/imageStatusGetResponse.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/raider/home/deliveryList.dart';

class DeliveryListMap extends StatefulWidget {
  const DeliveryListMap({super.key});

  @override
  State<DeliveryListMap> createState() => _DeliveryListMapState();
}

class _DeliveryListMapState extends State<DeliveryListMap> {
  late Future<List<ImageStatusGetResponse>?> loadDataStatus;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? senderLocation, receiverLocation, currentLocation;
  bool isLoading = true;
  bool isAtSender = false;
  bool isAtReceiver = false;
  bool CFisAtSender = false;
  bool CFisAtReceiver = false;
  late Stream<Position> positionStream;
  late StreamSubscription<Position> positionSubscription;
  late Future<OrdersGetData> orderData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? orderId;
  bool _dialogShown = false;
  File? statusImage;
  String imageUrl = '';
  List<ImageStatusGetResponse>? _cachedStatusData;
  bool _isStatusDataLoaded = false;

  final String googleMapsApiKey = 'AIzaSyCAcu7KNBNl-YiZ9YsZiZ6jpQQYmdXwjYU';

  final mapStyle = '''[
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}, {"lightness": 17}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#f5f5f5"}, {"lightness": 20}]},
    {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#ffffff"}, {"lightness": 17}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#ffffff"}, {"lightness": 29}, {"weight": 0.2}]},
    {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}, {"lightness": 19}]}
  ]''';

  void handleImageChanged(File image) {
    setState(() {
      statusImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDataStatus = fetchStatusData();
    orderId = Get.arguments?.toString();
    if (orderId == null) {
      Get.snackbar('Error', 'Order ID is required');
      return;
    }
    orderData = fetchOrderData(int.parse(orderId!));
    _initializeLocations();
    _initializeLocationTracking();
  }

  // เพิ่มฟังก์ชันสำหรับรีเซ็ตข้อมูล cache (ถ้าต้องการอัพเดทข้อมูลใหม่)
  void resetStatusData() {
    setState(() {
      _cachedStatusData = null;
      _isStatusDataLoaded = false;
    });
  }

  @override
  void dispose() {
    // เคลียร์ข้อมูล cache เมื่อ dispose
    _cachedStatusData = null;
    _isStatusDataLoaded = false;
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
                onTap: (_) => _dialogShown =
                    false, // Reset dialog flag when map is tapped
              ),
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
                    late int status = order_detail.status;
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
                                            color: _getStatusColor(
                                                order_detail.status),
                                            borderRadius:
                                                const BorderRadius.all(
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
                                    if (status == 3)
                                      Column(
                                        children: [
                                          const SizedBox(height: 15),
                                          Container(
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'ผู้ส่ง',
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF7B7B7C),
                                                          ),
                                                        ),
                                                        Text(
                                                          order_detail
                                                              .sender_name,
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        size: 45),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'ผู้รับ',
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF7B7B7C),
                                                          ),
                                                        ),
                                                        Text(
                                                          order_detail
                                                              .receiver_name,
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                FutureBuilder<
                                                    List<
                                                        ImageStatusGetResponse>?>(
                                                  future:
                                                      fetchStatusData(), // ฟังก์ชันที่ดึงข้อมูล
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // แสดง loading ขณะรอข้อมูล
                                                      return CircularProgressIndicator();
                                                    } else if (snapshot
                                                        .hasError) {
                                                      // แสดงข้อความเมื่อเกิดข้อผิดพลาด
                                                      return Text(
                                                          'เกิดข้อผิดพลาดในการโหลดข้อมูล');
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        snapshot
                                                            .data!.isEmpty) {
                                                      // กรณีไม่มีข้อมูล
                                                      return Text(
                                                          'ไม่มีข้อมูล');
                                                    }

                                                    // กรณีมีข้อมูล ให้แสดงรายการภาพสถานะ
                                                    final statusData =
                                                        snapshot.data!;

                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'ภาพประกอบสถานะ',
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    'SukhumvitSet',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF7B7B7C),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        ListView.builder(
                                                          shrinkWrap:
                                                              true, // ปรับขนาดตามจำนวนข้อมูล
                                                          physics:
                                                              NeverScrollableScrollPhysics(), // ป้องกันการสกรอลใน ListView ซ้อนกัน
                                                          itemCount:
                                                              statusData.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final item =
                                                                statusData[
                                                                    index];
                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                    height: 20),
                                                                Center(
                                                                  child: Text(
                                                                    _picStatusMessage(
                                                                        item.status), // แสดงสถานะ
                                                                    style:
                                                                        const TextStyle(
                                                                      fontFamily:
                                                                          'SukhumvitSet',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xFFFFFFFF),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    height: 200,
                                                                    width: 200,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16), // ทำมุมโค้งกับ ClipRRect
                                                                      child: Image
                                                                          .network(
                                                                        item.image_status, // แสดงภาพสถานะ
                                                                        height:
                                                                            200,
                                                                        width: double
                                                                            .infinity,
                                                                        fit: BoxFit
                                                                            .cover, // ทำให้ภาพเต็ม Container
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
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

  String _picStatusMessage(int status) {
    switch (status) {
      case 2:
        return 'ภาพหลักฐานไรเดอร์รับสินค้าจากผู้ส่ง'; // เปลี่ยนข้อความที่นี่
      case 3:
        return 'ภาพหลักฐานไรเดอร์ส่งสินค้าสำเร็จ'; // เปลี่ยนข้อความที่นี่
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          List<LatLng> route = [];
          for (var step in data['routes'][0]['legs'][0]['steps']) {
            final String polyline = step['polyline']['points'];
            route.addAll(_decodePoly(polyline));
          }
          return route;
        }
        throw Exception('Route not found: ${data['status']}');
      }
      throw Exception('Failed to load directions: ${response.statusCode}');
    } catch (e) {
      print('Error fetching route: $e');
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

  Future<OrdersGetData> fetchOrderData(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/rider/orders/$orderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return OrdersGetData.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load order data: ${response.statusCode}');
    } catch (e) {
      print('Error fetching order data: $e');
      rethrow;
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

  Future<List<ImageStatusGetResponse>?> fetchStatusData() async {
    if (_isStatusDataLoaded && _cachedStatusData != null) {
      return _cachedStatusData;
    }

    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/rider/orders/image/status/orderID/$orderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          // แปลงข้อมูลและเก็บใน cache
          _cachedStatusData = responseData
              .map((data) => ImageStatusGetResponse.fromJson(data))
              .toList();
          _isStatusDataLoaded = true;
          return _cachedStatusData;
        } else {
          _cachedStatusData = [];
          _isStatusDataLoaded = true;
          return [];
        }
      } else if (response.statusCode == 404) {
        _cachedStatusData = null;
        _isStatusDataLoaded = true;
        return null;
      } else {
        throw Exception('Failed to load status data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching status data: $e');
      return null;
    }
  }
}

OverlayEntry _createOverlayEntry() {
  return OverlayEntry(
    builder: (context) => Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Image.asset(
          'assets/gif/load.gif',
          width: 150,
          height: 150,
        ),
      ),
    ),
  );
}
