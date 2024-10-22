import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/animations/AnimatedCheckmark.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Request/UsersLoginPostRequest.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:runtod_app/pages/raider/home/riderHome.dart';
import 'package:runtod_app/pages/user/home/homeUser.dart';
import 'package:runtod_app/pages/option-register/option_register.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  String errorText = '';
  final TextEditingController usernameOrEmailOrPhoneCtl =
      TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double customPadding = isPortrait ? 20.0 : 60.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: customPadding, vertical: 100),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'ยินดีต้อนรับ',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'SukhumvitSet',
                    ),
                  ),
                  const Text(
                    'เข้าสู่ระบบของคุณ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C6C6C),
                      fontFamily: 'SukhumvitSet',
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextField(
                    controller: usernameOrEmailOrPhoneCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'ชื่อผู้ใช้ อีเมล หรือ เบอร์โทร',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordCtl,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'รหัสผ่าน',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white, // ตั้งค่าสีของไอคอนเป็นสีขาว
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'ลืมรหัสผ่านหรือไม่?',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: login,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF92A47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'หากคุณยังไม่มีบัญชี?',
                        style: TextStyle(
                          fontFamily: 'SukhumvitSet',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      TextButton(
                        onPressed: _register,
                        child: const Text(
                          'สร้างผู้ใช้ใหม่',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> login() async {
    log('username or email: ${usernameOrEmailOrPhoneCtl.text}');
    log('password: ${passwordCtl.text}');

    if (usernameOrEmailOrPhoneCtl.text.isEmpty || passwordCtl.text.isEmpty) {
      setState(() {
        errorText = 'กรุณาใส่ข้อมูลให้ครบทุกช่อง';
      });
      _showErrorDialog('กรุณาใส่ข้อมูลให้ครบทุกช่อง');
      return;
    }

    var data = UsersLoginPostRequest(
      usernameOrEmailOrPhone: usernameOrEmailOrPhoneCtl.text,
      password: passwordCtl.text,
    );
    log('Sending data: ${jsonEncode(data.toJson())}');

    try {
      var response = await http.post(
        Uri.parse('$API_ENDPOINT/login'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        if (responseData['users'] != null) {
          UsersLoginPostResponse users =
              UsersLoginPostResponse.fromJson(responseData['users']);

          int userType = users.type;
          int uid = users.uid;

          if (userType == 0) {
            GetStorage gs = GetStorage();
            gs.write('uid', uid);
            gs.write('type', userType);
            log("UID written: $uid");
            Get.to(() => const HomeUserPage());
          } else if (userType == 1) {
            GetStorage gs = GetStorage();
            gs.write('uid', uid);
            gs.write('type', userType);
            log("UID written: $uid");
            Get.to(() => const Riderhome());
          } else {
            _showErrorDialog('ไม่สามารถกำหนดประเภทผู้ใช้ได้');
          }
        } else {
          _showErrorDialog('ข้อมูลผู้ใช้ไม่ถูกต้อง');
        }
      } else {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        String errorMessage = 'ชื่อผู้ใช้ หรือ อีเมล และ รหัสผ่านไม่ถูกต้อง';

        setState(() {
          errorText = errorMessage;
        });
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      log('Error: $e');
      setState(() {
        errorText = 'ไม่สามารถเข้าสู่ระบบได้ ลองใหม่อีกครั้ง';
      });
      _showErrorDialog('ไม่สามารถเข้าสู่ระบบได้ ลองใหม่อีกครั้ง');
    }
  }

  void _register() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const OptionRegisterPage();
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ),
                ),
              ),
              Container(
                height: 210,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    const AnimatedCheckmark(isSuccess: false),
                    const SizedBox(height: 10),
                    const Text(
                      ' เข้าสู่ระบบไม่สำเร็จ',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            color: Color(0xffB3B3B3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextButton(
                                  child: const Text(
                                    'ตกลง',
                                    style: TextStyle(
                                      fontFamily: 'SukhumvitSet',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
