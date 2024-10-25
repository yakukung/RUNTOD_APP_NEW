import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:runtod_app/model/Response/ordersGetResponse.dart';
import 'package:runtod_app/pages/intro.dart';
import 'dart:convert';

import 'package:runtod_app/pages/nav-user/navbar.dart';
import 'package:runtod_app/pages/nav-user/riderNavbottom.dart';
import 'package:runtod_app/pages/raider/home/deliveryListMap.dart';
import 'package:runtod_app/pages/raider/home/ridermapTwo.dart';
import 'package:runtod_app/sidebar/riderSidebar.dart';

class Deliverylist extends StatefulWidget {
  const Deliverylist({super.key});

  @override
  State<Deliverylist> createState() => _DeliverylistState();
}

class _DeliverylistState extends State<Deliverylist> {
  GetStorage gs = GetStorage();
  late Future<UsersLoginPostResponse> loadDataUser;
  late Future<List<OrdersGetData>> loadDataOrders;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int order_id = 0;

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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: customPadding, top: customPadding),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รายการที่ส่ง',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color(0xFFFFFFFF))),
                      Text('ดูรายการทั้งหมดที่คุณส่ง',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF7B7B7C))),
                    ],
                  ),
                ),
                FutureBuilder<List<OrdersGetData>>(
                  future: loadDataOrders,
                  builder: (BuildContext context, orderSnapshot) {
                    if (orderSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (orderSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${orderSnapshot.error}'));
                    } else if (!orderSnapshot.hasData ||
                        orderSnapshot.data!.isEmpty) {
                      // เช็คกรณีที่ไม่มีข้อมูล
                      return const Center(
                          child: Text('ไม่มีออเดอร์ที่กำลังจัดส่ง',
                              style: TextStyle(
                                  fontFamily: 'SukhumvitSet',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF7B7B7C))));
                    }
                    final orders = orderSnapshot.data!;
                    // นำเสนอข้อมูลทั้งหมดในรายการ
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(45)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('เลขพัสดุ ${order.order_id}',
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
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                      order.status),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(45)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _getStatusMessage(
                                                        order.status),
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'SukhumvitSet',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Color(0xFFFFFFFF),
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
                                                        color:
                                                            Color(0xFFFFFFFF))),
                                                const SizedBox(height: 2),
                                                Text(order.sender_address,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'SukhumvitSet',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF7B7B7C))),
                                                const SizedBox(height: 10),
                                                const Icon(
                                                    Icons
                                                        .arrow_downward_rounded,
                                                    size: 45),
                                                const SizedBox(height: 10),
                                                Text(
                                                    'ผู้รับ : ${order.receiver_name}',
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'SukhumvitSet',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFFFFFFFF))),
                                                const SizedBox(height: 2),
                                                Text(order.receiver_address,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'SukhumvitSet',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF7B7B7C))),
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
                                                    if (order.status != 3)
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            _RiderMapTwo(
                                                                order.order_id),
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
                                                    if (order.status == 3)
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            _OrderDetail(
                                                                order.order_id),
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
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Ridernavbottom(
        selectedIndex: 1,
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

  Future<List<OrdersGetData>> fetchOrdersData() async {
    GetStorage gs = GetStorage();
    int uid = gs.read('uid');
    final response = await http.get(
      Uri.parse('$API_ENDPOINT/rider/orders/list-delivery/$uid'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData.isEmpty) {
        return [];
      }

      return List<OrdersGetData>.from(
          responseData.map((order) => OrdersGetData.fromJson(order)));
    } else if (response.statusCode == 404) {
      return []; // คืนค่าเป็น list ว่าง
    } else {
      throw Exception('Failed to load orders data: ${response.reasonPhrase}');
    }
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

  Future<void> _RiderMapTwo(int orderId) async {
    gs.write('oid', orderId.toString());
    Get.to(() => const RidermapTwo());
  }

  Future<void> _OrderDetail(int orderId) async {
    log('ส่งค่าไป $orderId');
    Get.to(() => const DeliveryListMap(), arguments: orderId);
  }
}
