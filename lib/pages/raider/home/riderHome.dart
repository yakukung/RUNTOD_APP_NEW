import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/intro.dart';
import 'package:runtod_app/pages/nav-user/navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:runtod_app/pages/nav-user/riderNavbottom.dart';
import 'package:runtod_app/pages/raider/home/ridermap.dart';
import 'package:runtod_app/sidebar/riderSidebar.dart';

class Riderhome extends StatefulWidget {
  const Riderhome({super.key});

  @override
  State<Riderhome> createState() => _RiderhomeState();
}

class _RiderhomeState extends State<Riderhome> {
  late Future<UsersLoginPostResponse> loadDataUser;
  late Future<OrdersGetData> loadDataOrders;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int order_id = 0; // หรือค่าเริ่มต้นที่คุณต้องการ

  @override
  void initState() {
    super.initState();
    loadDataUser = fetchUserData();
    loadDataOrders = fetchOrdersData();
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
            return Ridersidebar(
              imageUrl: snapshot.data!.imageProfile ?? '',
              fullname: snapshot.data!.fullname,
              uid: snapshot.data!.uid,
              currentPage: 'home',
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
                      const Text('ยินดีต้อนรับกลับมา เหล่านักซิ่ง!',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF7B7B7C))),
                      Text(user.fullname,
                          style: const TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color(0xFFFFFFFF))),
                      const Text('(ไรเดอร์)',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF7B7B7C))),
                      FutureBuilder<OrdersGetData>(
                        future: loadDataOrders,
                        builder: (BuildContext context, orderSnapshot) {
                          if (!orderSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final order = orderSnapshot.data!;
                          order_id = order.order_id;
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 380,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1D1D1F),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                45)), // แก้ไขให้เป็น BorderRadius.all
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'เลขพัสดุ ${order.order_id}',
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'SukhumvitSet',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF7B7B7C))),
                                                Container(
                                                  width: 120,
                                                  height: 30,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFF92A47),
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            45)), // แก้ไขให้เป็น BorderRadius.all
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      order.status == 0
                                                          ? 'รอไรเดอร์รับสินค้า'
                                                          : '${order.status}', // เช็คค่าของ order.status
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'SukhumvitSet',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'ผู้ส่ง : ${order.sender_name}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Color(
                                                              0xFFFFFFFF))),
                                                  const SizedBox(height: 2),
                                                  Text(order.sender_address,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF7B7B7C))),
                                                  const SizedBox(height: 10),
                                                  const Icon(
                                                    Icons
                                                        .arrow_downward_rounded,
                                                    size: 45,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                      'ผู้รับ : ${order.receiver_name}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Color(
                                                              0xFFFFFFFF))),
                                                  const SizedBox(height: 2),
                                                  Text(order.receiver_address,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF7B7B7C))),
                                                  const SizedBox(height: 15),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'จำนวน ${order.total_orders} รายการ',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'SukhumvitSet',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: _OrderDetail,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'รายละเอียดเพิ่มเติม',
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
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const Ridernavbottom(
        selectedIndex: 0,
      ),
    );
  }

  Future<UsersLoginPostResponse> fetchUserData() async {
    GetStorage gs = GetStorage();
    int uid = gs.read('uid');
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

  Future<OrdersGetData> fetchOrdersData() async {
    final response = await http.get(
      Uri.parse('$API_ENDPOINT/rider/orders'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return OrdersGetData.fromJson(responseData);
    } else {
      await _clearStorageAndNavigate();
      throw Exception('Failed to load orders data: ${response.reasonPhrase}');
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
      Get.offAll(() => const IntroPage());
    }
  }

  Future<void> _OrderDetail() async {
    log('ส่งค่าไป ${order_id}');
    Get.to(() => const Ridermap(), arguments: order_id);
  }
}
