import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/pages/intro.dart';
import 'package:runtod_app/pages/nav-user/navbar.dart';
import 'package:runtod_app/pages/nav-user/navbottom.dart';
import 'package:runtod_app/pages/user/home/addListProduct.dart';
import 'package:runtod_app/sidebar/userSidebar.dart';

class SenduserPage extends StatefulWidget {
  const SenduserPage({super.key});

  @override
  State<SenduserPage> createState() => _SenduserPageState();
}

class _SenduserPageState extends State<SenduserPage> {
  late Future<UsersLoginPostResponse> loadDataUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      backgroundColor: const Color(0xFF000000),
      key: _scaffoldKey,
      appBar: Navbar(loadDataUser: loadDataUser, scaffoldKey: _scaffoldKey),
      drawer: FutureBuilder<UsersLoginPostResponse>(
        future: loadDataUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return CustomerSidebar(
              imageUrl: snapshot.data!.imageProfile ?? '',
              fullname: snapshot.data!.fullname,
              uid: snapshot.data!.uid,
              currentPage: 'send',
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
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
                Padding(
                  padding:
                      EdgeInsets.only(left: customPadding, top: customPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullname,
                          style: const TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color(0xFFFFFFFF))),
                      const Text('รายการสินค้าที่ต้องส่ง',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF7B7B7C))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: customPadding, right: customPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: FilledButton(
                          onPressed: () {
                            Get.to(() => Addproduct());
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E2E30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.minPositive,
                                35), // ปรับขนาดให้พอดีกับปุ่ม
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_box,
                                  color: Color(0xFFFFFFFF), size: 20),
                              SizedBox(width: 5),
                              Text(
                                'เพิ่มรายการส่ง',
                                style: TextStyle(
                                  fontFamily: 'SukhumvitSet',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: customPadding),
                      SizedBox(
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.minPositive,
                                35), // ปรับขนาดให้พอดีกับปุ่ม
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 20),
                              SizedBox(width: 5),
                              Text(
                                'ยืนยันการส่ง',
                                style: TextStyle(
                                  fontFamily: 'SukhumvitSet',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavBottom(
        selectedIndex: 1,
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
}
