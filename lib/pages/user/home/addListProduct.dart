import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/pages/intro.dart';
import 'package:runtod_app/pages/nav-user/navbar.dart';
import 'package:runtod_app/pages/nav-user/navbottom.dart';
import 'package:runtod_app/sidebar/userSidebar.dart';
import 'package:runtod_app/widget/profilePictureWidget.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  late Future<UsersLoginPostResponse> loadDataUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String imageUrl = '';
  File? profileImage;

  @override
  void initState() {
    super.initState();
    loadDataUser = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    MediaQuery.of(context).size.height;
    double customPadding = isPortrait ? 15.0 : 60.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // ไอคอนเริ่มต้นย้อนกลับ
          onPressed: () {
            Navigator.pop(context); // เมื่อกดจะย้อนกลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<UsersLoginPostResponse>(
          future: loadDataUser,
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = userSnapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<UsersLoginPostResponse>(
                      future: loadDataUser,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return GestureDetector(
                            onTap: () async {
                              // ฟังก์ชันสำหรับการเลือกไฟล์ใหม่
                              File? newImage = await _pickImage();
                              if (newImage != null) {
                                setState(() {
                                  profileImage = newImage;
                                });
                                print('New image selected: ${newImage.path}');
                              }
                            },
                            child: Container(
                              width: 100, // ขนาดของกรอบสี่เหลี่ยม
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200], // สีพื้นหลัง
                                border:
                                    Border.all(color: Colors.grey), // สีของขอบ
                                borderRadius: BorderRadius.circular(
                                    8), // มุมโค้งของสี่เหลี่ยม
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add, // เครื่องหมายบวก
                                  size: 80,
                                  color: Colors.grey, // สีของเครื่องหมายบวก
                                ),
                              ),
                            ),
                          );      
                          
                        } else {
                          return const Text('No data available');
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<UsersLoginPostResponse> fetchUserData() async {
    GetStorage gs = GetStorage();
    int? uid = gs.read('uid');

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

  Future<File?> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path); // แปลงไฟล์เป็น File
    }
    return null; // กรณีไม่เลือกไฟล์
  }
}
