import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:runtod_app/pages/intro.dart';

class SetReceivingPage extends StatefulWidget {
  const SetReceivingPage({super.key});

  @override
  State<SetReceivingPage> createState() => _SetReceivingPageState();
}

class _SetReceivingPageState extends State<SetReceivingPage> {
  final loc.Location _location = loc.Location();
  LatLng _currentPosition = const LatLng(13.7563, 100.5018);
  LatLng? _originalPosition;
  String _address = "";
  bool _isLoading = true;
  bool _isUpdatingAddress = false;
  MapController mapController = MapController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition,
                    initialZoom: 15.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        _updateAddress(position.center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            top: 50,
            left: 10,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Transform.translate(
                    offset: Offset(-1.0, 0.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    onPressed: _goToCurrentPosition,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1D1D1F),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    const SizedBox(height: 20),
                    const Text(
                      'ที่อยู่ของฉัน',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C6C6C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isUpdatingAddress
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            _address.isNotEmpty
                                ? _address
                                : 'กำลังค้นหาที่อยู่...',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 114,
                      child: FilledButton(
                        onPressed: _saveAddress,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1F8CE2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'บันทึกที่อยู่',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        _originalPosition = _currentPosition;
        _isLoading = false;
      });
      _getAddressFromLatLng();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getAddressFromLatLng() async {
    try {
      setState(() {
        _isUpdatingAddress = true;
      });
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
          _isUpdatingAddress = false;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _isUpdatingAddress = false;
      });
    }
  }

  void _updateAddress(LatLng newPosition) {
    setState(() {
      _currentPosition = newPosition;
      _isUpdatingAddress = true;
    });

    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _getAddressFromLatLng();
    });
  }

  void _goToCurrentPosition() {
    if (_originalPosition != null) {
      mapController.move(_originalPosition!, 15.0);
      _updateAddress(_originalPosition!);
    }
  }

  Future<UsersLoginPostResponse> fetchUserData() async {
    GetStorage gs = GetStorage();
    String? uid = gs.read('uid');

    final response = await http.get(
      Uri.parse('$API_ENDPOINT/user/$uid'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return UsersLoginPostResponse.fromJson(responseData);
    } else {
      await _clearStorageAndNavigate();
      throw Exception('Failed to load user data: ${response.reasonPhrase}');
    }
  }

  Future<void> _clearStorageAndNavigate() async {
    try {
      GetStorage gs = GetStorage();
      await gs.erase();
      print('Storage cleared successfully');
    } catch (e) {
      print('Error clearing storage: $e');
    } finally {
      Get.offAll(() => IntroPage());
    }
  }

  Future<void> _saveAddress() async {
    GetStorage gs = GetStorage();
    var uid = gs.read('uid');

    if (uid != null) {
      // แสดงป๊อปอัพเพื่อยืนยันการบันทึก
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ยืนยันการบันทึก"),
            content: Text("คุณแน่ใจหรือว่าต้องการบันทึกที่อยู่รับสินค้า?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("ยกเลิก"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("ยืนยัน"),
              ),
            ],
          );
        },
      );
      if (confirm == true) {
        try {
          final response = await http.put(
            Uri.parse('$API_ENDPOINT/user/set/receiving_address'),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: json.encode({"uid": uid, "receiving_address": _address}),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            Get.snackbar(
              '',
              '',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.blue,
              margin: EdgeInsets.all(30),
              borderRadius: 20,
              titleText: Text(
                'ที่อยู่รับสินค้าของคุณ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'SukhumvitSet',
                ),
              ),
              messageText: Text(
                _address,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SukhumvitSet',
                ),
              ),
            );
            print("ที่อยู่ถูกบันทึกเรียบร้อยแล้ว: $data");
          } else {
            print("เกิดข้อผิดพลาดในการบันทึกที่อยู่: ${response.reasonPhrase}");
          }
        } catch (e) {
          print("ข้อผิดพลาดในการบันทึกที่อยู่: $e");
        }
        print("บันทึกที่อยู่: $_address, uid: ${uid.toString()}");
      } else {
        print("การบันทึกที่อยู่ถูกยกเลิก");
      }
    } else {
      print("UID not found");
    }
  }
}
