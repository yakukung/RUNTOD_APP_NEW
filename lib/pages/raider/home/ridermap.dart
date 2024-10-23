import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';

class Ridermap extends StatefulWidget {
  const Ridermap({super.key});
  @override
  State<Ridermap> createState() => _RidermapState();
}

class _RidermapState extends State<Ridermap> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? senderLocation, receiverLocation;
  bool isLoading = true;
  late Future<OrdersGetData> orderData;

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
    orderData = fetchOrderData(Get.arguments);
    _initializeLocations();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(mapStyle);
    if (senderLocation != null && receiverLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
                min(senderLocation!.latitude, receiverLocation!.latitude),
                min(senderLocation!.longitude, receiverLocation!.longitude)),
            northeast: LatLng(
                max(senderLocation!.latitude, receiverLocation!.latitude),
                max(senderLocation!.longitude, receiverLocation!.longitude)),
          ),
          120));
    }
  }

  Future<OrdersGetData> fetchOrderData(int orderId) async {
    final response = await http.get(
        Uri.parse('$API_ENDPOINT/rider/orders/$orderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200)
      return OrdersGetData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load order data: ${response.reasonPhrase}');
  }

  Future<void> _initializeLocations() async {
    try {
      final order = await orderData;
      List<Location> senderLocations =
          await locationFromAddress(order.sender_address);
      if (senderLocations.isNotEmpty) {
        senderLocation = LatLng(
            senderLocations.first.latitude, senderLocations.first.longitude);
        markers.add(Marker(
            markerId: const MarkerId('sender'),
            position: senderLocation!,
            infoWindow: InfoWindow(
                title: 'ผู้ส่ง: ${order.sender_name}',
                snippet: order.sender_address),
            icon: BitmapDescriptor.defaultMarker));
      }
      List<Location> receiverLocations =
          await locationFromAddress(order.receiver_address);
      if (receiverLocations.isNotEmpty) {
        receiverLocation = LatLng(receiverLocations.first.latitude,
            receiverLocations.first.longitude);
        markers.add(Marker(
            markerId: const MarkerId('receiver'),
            position: receiverLocation!,
            infoWindow: InfoWindow(
                title: 'ผู้รับ: ${order.receiver_name}',
                snippet: order.receiver_address),
            icon: BitmapDescriptor.defaultMarker));
        polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: [senderLocation!, receiverLocation!],
            color: const Color(0xFF4CAF50),
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(8)],
            endCap: Cap.roundCap,
            startCap: Cap.roundCap));
      }
      setState(() => isLoading = false);
    } catch (e) {
      print('Error initializing locations: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 0,
          title: const Text('แผนที่การจัดส่ง',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SukhumvitSet',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back())),
      body: FutureBuilder<OrdersGetData>(
          future: orderData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                isLoading) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50))),
                    const SizedBox(height: 16),
                    Text('กำลังโหลดข้อมูล...',
                        style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontSize: 16,
                            color: Colors.grey[600])),
                  ]));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('เกิดข้อผิดพลาด: ${snapshot.error}',
                        style: const TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontSize: 16,
                            color: Colors.red),
                        textAlign: TextAlign.center),
                  ]));
            }
            return Stack(children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: senderLocation ?? const LatLng(13.7563, 100.5018),
                    zoom: 13),
                markers: markers,
                polylines: polylines,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                compassEnabled: true,
                buildingsEnabled: true,
                mapToolbarEnabled: true,
              ),
              if (senderLocation == null || receiverLocation == null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 24),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text('ไม่พบที่อยู่สำหรับผู้ส่งหรือผู้รับ',
                                  style: TextStyle(
                                      fontFamily: 'SukhumvitSet', fontSize: 16),
                                  textAlign: TextAlign.center)),
                        ]),
                  ),
                ),
            ]);
          }),
    );
  }
}
