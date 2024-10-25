import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
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
import 'package:runtod_app/model/Response/imageStatusGetResponse.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/raider/home/riderHome.dart';
import 'package:runtod_app/widget/statusPictureWiget.dart';

class RidermapTwo extends StatefulWidget {
  const RidermapTwo({super.key});

  @override
  State<RidermapTwo> createState() => _RidermapTwoState();
}

class _RidermapTwoState extends State<RidermapTwo> {
  late Future<ImageStatusGetResponse?> loadDataStatus;
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
  double initialChildSize = 0.3;
  double minChildSize = 0.3;
  double maxChildSize = 0.8;

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
    orderId = GetStorage().read<String>('oid');
    loadDataStatus = fetchStatusData();

    if (orderId == null) {
      Get.snackbar(
        'Error',
        'Order ID is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // เริ่มต้นโหลดข้อมูล
    _loadAllData();
  }

// ฟังก์ชันสำหรับโหลดข้อมูลทั้งหมด
  Future<void> _loadAllData() async {
    int retryCount = 0;
    const maxRetries = 3; // จำนวนครั้งสูงสุดที่จะลองใหม่
    const retryDelay = Duration(seconds: 3); // ระยะเวลารอระหว่างการลองใหม่

    while (retryCount < maxRetries) {
      try {
        setState(() {
          isLoading = true;
        });

        // โหลดข้อมูล order
        orderData = fetchOrderData(orderId);
        final orders = await orderData;

        // ตรวจสอบข้อมูลที่จำเป็น
        if (orders.sender_address == null ||
            orders.receiver_address == null ||
            orders.sender_address.isEmpty ||
            orders.receiver_address.isEmpty) {
          throw Exception('Missing address information');
        }

        // เริ่มการติดตามตำแหน่ง
        await _initializeLocationTracking();

        // เริ่มการโหลดตำแหน่ง
        await _initializeLocations();

        // ถ้าทุกอย่างสำเร็จ ออกจาก loop
        break;
      } catch (e) {
        print('Error loading data (attempt ${retryCount + 1}): $e');
        retryCount++;

        if (retryCount < maxRetries) {
          // แสดง snackbar ว่ากำลังจะลองใหม่
          if (mounted) {
            Get.snackbar(
              'Loading Error',
              'Retrying in ${retryDelay.inSeconds} seconds... (Attempt ${retryCount + 1}/$maxRetries)',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: retryDelay,
            );
          }

          // รอก่อนที่จะลองใหม่
          await Future.delayed(retryDelay);
        } else {
          // ถ้าลองครบจำนวนครั้งแล้วยังไม่สำเร็จ
          if (mounted) {
            Get.snackbar(
              'Error',
              'Failed to load data after $maxRetries attempts. Please try again later.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          }
        }
      }
    }
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
                        initialChildSize: initialChildSize,
                        minChildSize: minChildSize,
                        maxChildSize: maxChildSize,
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
                                    if (status == 1)
                                      Column(
                                        children: [
                                          const Text(
                                            'ระยะทางถึงจุดผู้ส่ง',
                                            style: TextStyle(
                                              fontFamily: 'SukhumvitSet',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF7B7B7C),
                                            ),
                                          ),
                                          Text(
                                            '${Geolocator.distanceBetween(
                                              currentLocation!.latitude,
                                              currentLocation!.longitude,
                                              senderLocation!.latitude,
                                              senderLocation!.longitude,
                                            ).toStringAsFixed(0)} เมตร',
                                            style: const TextStyle(
                                              fontFamily: 'SukhumvitSet',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
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
                                                  const Text(
                                                    'ผู้ส่ง',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF7B7B7C),
                                                    ),
                                                  ),
                                                  Text(
                                                    order_detail.sender_name,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 45),
                                              const SizedBox(width: 10),
                                              Column(
                                                children: [
                                                  const Text(
                                                    'ผู้รับ',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF7B7B7C),
                                                    ),
                                                  ),
                                                  Text(
                                                    order_detail.receiver_name,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          if (isAtSender == true)
                                            Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          'กรุณาถ่ายภาพหลักฐานการรับสินค้าจากผู้ส่ง',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    FutureBuilder<
                                                        ImageStatusGetResponse?>(
                                                      future: loadDataStatus,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final imageUrl =
                                                              snapshot.data
                                                                  ?.image_status;
                                                          if (imageUrl !=
                                                                  null &&
                                                              imageUrl
                                                                  .isNotEmpty) {
                                                            return StatusPictureWidget(
                                                              imageUrl:
                                                                  imageUrl,
                                                              onImageChanged:
                                                                  (File
                                                                      newImage) {
                                                                statusImage =
                                                                    newImage;
                                                                dev.log(
                                                                    'New image selected: ${newImage.path}');
                                                              },
                                                            );
                                                          } else {
                                                            return const Text(
                                                                'No image available');
                                                          }
                                                        } else {
                                                          return StatusPictureWidget(
                                                            imageUrl: imageUrl,
                                                            onImageChanged:
                                                                (File
                                                                    newImage) {
                                                              statusImage =
                                                                  newImage;
                                                              dev.log(
                                                                  'New image selected: ${newImage.path}');
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(height: 15),
                                                    ElevatedButton(
                                                      onPressed: _saveStatusOne,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'เริ่มการส่งสินค้า',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    if (status == 2)
                                      Column(
                                        children: [
                                          const Text(
                                            'ระยะทางถึงจุดผู้รับ',
                                            style: TextStyle(
                                              fontFamily: 'SukhumvitSet',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF7B7B7C),
                                            ),
                                          ),
                                          Text(
                                            '${Geolocator.distanceBetween(
                                              currentLocation!.latitude,
                                              currentLocation!.longitude,
                                              receiverLocation!.latitude,
                                              receiverLocation!.longitude,
                                            ).toStringAsFixed(0)} เมตร',
                                            style: const TextStyle(
                                              fontFamily: 'SukhumvitSet',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          if (isAtReceiver == true)
                                            Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          'กรุณาถ่ายภาพหลักฐานไรเดอร์นำส่งสินค้าเสร็จสิ้น',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SukhumvitSet',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    FutureBuilder<
                                                        ImageStatusGetResponse?>(
                                                      future: loadDataStatus,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final imageUrl =
                                                              snapshot.data
                                                                  ?.image_status;
                                                          if (imageUrl !=
                                                                  null &&
                                                              imageUrl
                                                                  .isNotEmpty) {
                                                            return StatusPictureWidget(
                                                              imageUrl:
                                                                  imageUrl,
                                                              onImageChanged:
                                                                  (File
                                                                      newImage) {
                                                                statusImage =
                                                                    newImage;
                                                                dev.log(
                                                                    'New image selected: ${newImage.path}');
                                                              },
                                                            );
                                                          } else {
                                                            return const Text(
                                                                'No image available');
                                                          }
                                                        } else {
                                                          return StatusPictureWidget(
                                                            imageUrl: imageUrl,
                                                            onImageChanged:
                                                                (File
                                                                    newImage) {
                                                              statusImage =
                                                                  newImage;
                                                              dev.log(
                                                                  'New image selected: ${newImage.path}');
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(height: 15),
                                                    ElevatedButton(
                                                      onPressed: _saveStatusTwo,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'ส่งสินค้าเสร็จสิ้น',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    if (status == 3)
                                      Column(
                                        children: [
                                          const SizedBox(height: 15),
                                          if (isAtReceiver == true)
                                            Column(
                                              children: [
                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          'ผู้ส่ง',
                                                          style: TextStyle(
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
                                                    const Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        size: 45),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          'ผู้รับ',
                                                          style: TextStyle(
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
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    GetStorage gs =
                                                        GetStorage();
                                                    gs.remove('oid');

                                                    Get.offAll(() =>
                                                        const Riderhome());
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'กลับหน้าหลัก',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
      isAtSender = distanceToSender <= 5;
      isAtReceiver = distanceToReceiver <= 555;
    });

    if (!_dialogShown) {
      dev.log('Entering the if condition', name: 'Snackbar Debug');

      if (isAtSender && !wasAtSender) {
        _dialogShown = true;
        initialChildSize = 0.6;
        _showDestinationReachedDialog(
          'แจ้งเตือน!!',
          'คุณมาถึงจุดรับสินค้าแล้ว',
          backgroundColor: Colors.blue,
        );
      } else if (isAtReceiver && !wasAtReceiver) {
        _dialogShown = true;
        initialChildSize = 0.6;
        _showDestinationReachedDialog(
          'แจ้งเตือน!!',
          'คุณมาถึงจุดส่งสินค้าแล้ว',
          backgroundColor: Colors.blue,
        );
      }
    }
  }

  void _showDestinationReachedDialog(String title, String message,
      {Color backgroundColor = Colors.blue}) {
    if (!mounted) return;

    {
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

  Future<OrdersGetData> fetchOrderData(String? orderId) async {
    if (orderId == null || orderId.isEmpty) {
      throw Exception('OrderId is required');
    }

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

  Future<void> _initializeLocations() async {
    if (!mounted) return;

    // ตรวจสอบ orderId ก่อนใช้งาน
    if (orderId == null) {
      Get.snackbar(
        'Error',
        'Order ID is missing',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final orders = await fetchOrderData(orderId);

      // ตรวจสอบที่อยู่ก่อนแปลงเป็นพิกัด
      if (orders.sender_address == null || orders.sender_address.isEmpty) {
        throw Exception('Sender address is missing');
      }
      if (orders.receiver_address == null || orders.receiver_address.isEmpty) {
        throw Exception('Receiver address is missing');
      }

      List<Location> senderLocations =
          await locationFromAddress(orders.sender_address);
      LatLng? tempSenderLocation;
      if (senderLocations.isNotEmpty) {
        tempSenderLocation = LatLng(
          senderLocations.first.latitude,
          senderLocations.first.longitude,
        );
      }

      List<Location> receiverLocations =
          await locationFromAddress(orders.receiver_address);
      LatLng? tempReceiverLocation;
      if (receiverLocations.isNotEmpty) {
        tempReceiverLocation = LatLng(
          receiverLocations.first.latitude,
          receiverLocations.first.longitude,
        );
      }

      if (!mounted) return;

      setState(() {
        senderLocation = tempSenderLocation;
        receiverLocation = tempReceiverLocation;

        if (senderLocation != null) {
          markers.add(Marker(
            markerId: const MarkerId('sender'),
            position: senderLocation!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    } catch (e) {
      print('Error initializing locations: $e');
      if (!mounted) return;

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

  Future<ImageStatusGetResponse?> fetchStatusData() async {
    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/rider/orders/image/status/$orderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData.isEmpty) {
          return null;
        }
        return ImageStatusGetResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load orders data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching status data: $e');
      return null;
    }
  }

  Future<void> _saveStatusOne() async {
    CFisAtSender = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (statusImage == null) {
        _showDestinationReachedDialog(
          'ไม่สำเร็จ!',
          'กรุณาถ่ายภาพเก็บหลักฐานก่อน',
          backgroundColor: const Color(0xFFF92A47),
        );
        return;
      }
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
                        color: const Color(0xFF4A4A4C),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      'ยืนยันส่งข้อมูล',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'คุณต้องการส่งภาพนี้ใช่ไหม?',
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
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
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
                            final overlayState = Overlay.of(context);
                            if (overlayState == null) {
                              _showDestinationReachedDialog(
                                'Error!',
                                'Cannot find overlay in the current context',
                                backgroundColor: const Color(0xFFF92A47),
                              );
                              return;
                            }

                            OverlayEntry overlayEntry = _createOverlayEntry();
                            overlayState.insert(overlayEntry);

                            String? imageUrl;
                            int statusInt = 2;
                            String status = statusInt.toString();

                            try {
                              if (statusImage != null) {
                                String? order_id = orderId;
                                imageUrl = await uploadImageToFirebase(
                                    order_id!, status, statusImage!);
                                if (imageUrl == null) {
                                  overlayEntry.remove();
                                  _showDestinationReachedDialog(
                                    'ไม่สำเร็จ!',
                                    'ไม่สามารถอัปโหลดรูปภาพได้!',
                                    backgroundColor: const Color(0xFFF92A47),
                                  );
                                  return;
                                }
                              }

                              dev.log(
                                  "Order ID: $orderId, Image URL: $imageUrl, Status: $status");

                              var data = ImageStatusGetResponse(
                                order_id: int.parse(orderId ?? '0'),
                                image_status: imageUrl ?? '',
                                status: statusInt,
                              );

                              var response = await http.post(
                                Uri.parse(
                                    '$API_ENDPOINT/rider/orders/image/status'),
                                headers: {
                                  "Content-Type":
                                      "application/json; charset=utf-8"
                                },
                                body: jsonEncode(data.toJson()),
                              );

                              dev.log(
                                  "Response Status: ${response.statusCode}");
                              dev.log("Response Body: ${response.body}");

                              if (response.statusCode == 200) {
                                _showDestinationReachedDialog(
                                  'สำเร็จ!',
                                  'อัพรูปสำเร็จแล้ว',
                                  backgroundColor: Colors.blue,
                                );
                                setState(() {
                                  orderData = fetchOrderData(orderId);
                                });
                              } else {
                                _showDestinationReachedDialog(
                                  'ไม่สำเร็จ!',
                                  'ไม่สำเร็จ',
                                  backgroundColor: const Color(0xFFF92A47),
                                );
                              }
                            } catch (e) {
                              _showDestinationReachedDialog(
                                  'ไม่สำเร็จ!', 'ลองใหม่อีกครั้ง',
                                  backgroundColor: const Color(0xFFF92A47));
                            } finally {
                              overlayEntry.remove();
                            }

                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
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
    });
  }

  Future<void> _saveStatusTwo() async {
    CFisAtReceiver = true;
    if (statusImage == null) {
      _showDestinationReachedDialog(
        'ไม่สำเร็จ!',
        'กรุณาถ่ายภาพเก็บหลักฐานก่อน',
        backgroundColor: const Color(0xFFF92A47),
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                        color: const Color(0xFF4A4A4C),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      'ยืนยันส่งข้อมูล',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'คุณต้องการส่งภาพนี้ใช่ไหม?',
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
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
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
                            final overlayState = Overlay.of(context);
                            if (overlayState == null) {
                              _showDestinationReachedDialog(
                                'Error!',
                                'Cannot find overlay in the current context',
                                backgroundColor: const Color(0xFFF92A47),
                              );
                              return;
                            }

                            OverlayEntry overlayEntry = _createOverlayEntry();
                            overlayState.insert(overlayEntry);

                            String? imageUrl;
                            int statusInt = 3;
                            String status = statusInt.toString();

                            try {
                              if (statusImage != null) {
                                String? order_id = orderId;
                                imageUrl = await uploadImageToFirebase(
                                    order_id!, status, statusImage!);
                                if (imageUrl == null) {
                                  overlayEntry.remove();
                                  _showDestinationReachedDialog(
                                    'ไม่สำเร็จ!',
                                    'ไม่สามารถอัปโหลดรูปภาพได้!',
                                    backgroundColor: const Color(0xFFF92A47),
                                  );
                                  return;
                                }
                              }

                              dev.log(
                                  "Order ID: $orderId, Image URL: $imageUrl, Status: $status");

                              var data = ImageStatusGetResponse(
                                order_id: int.parse(orderId ?? '0'),
                                image_status: imageUrl ?? '',
                                status: statusInt,
                              );

                              var response = await http.post(
                                Uri.parse(
                                    '$API_ENDPOINT/rider/orders/image/status/success'),
                                headers: {
                                  "Content-Type":
                                      "application/json; charset=utf-8"
                                },
                                body: jsonEncode(data.toJson()),
                              );

                              dev.log(
                                  "Response Status: ${response.statusCode}");
                              dev.log("Response Body: ${response.body}");

                              if (response.statusCode == 200) {
                                _showDestinationReachedDialog(
                                  'สำเร็จ!',
                                  'อัพรูปสำเร็จแล้ว',
                                  backgroundColor: Colors.blue,
                                );
                                setState(() {
                                  orderData = fetchOrderData(orderId);
                                });
                              } else {
                                _showDestinationReachedDialog(
                                  'ไม่สำเร็จ!',
                                  'ไม่สำเร็จ',
                                  backgroundColor: const Color(0xFFF92A47),
                                );
                              }
                            } catch (e) {
                              _showDestinationReachedDialog(
                                  'ไม่สำเร็จ!', 'ลองใหม่อีกครั้ง',
                                  backgroundColor: const Color(0xFFF92A47));
                            } finally {
                              overlayEntry
                                  .remove(); // Ensure overlayEntry is removed at the end
                            }

                            Navigator.of(context).pop(); // ปิด BottomSheet
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
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
    });
  }

  Future<String?> uploadImageToFirebase(
      String orderId, String status, File imageFile) async {
    try {
      final int fileSizeInBytes = await imageFile.length();
      if (fileSizeInBytes > 5 * 1024 * 1024) {
        debugPrint('File size too large: ${fileSizeInBytes / 1024 / 1024} MB');
        return null;
      }

      // ตรวจสอบนามสกุลไฟล์
      final String extension = path.extension(imageFile.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
        debugPrint('Invalid file type: $extension');
        return null;
      }

      try {
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('order_images/$orderId/$fileName');

        final UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          debugPrint(
              'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        }, onError: (e) {
          debugPrint('Upload error: $e');
        });

        final TaskSnapshot taskSnapshot = await uploadTask;
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        debugPrint('Upload successful. Download URL: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        debugPrint('Error in uploadImageToFirebase: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error in uploadImageToFirebase: $e');
      return null;
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
}
