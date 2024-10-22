import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/model/Request/UsersUpdateProfile.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/pages/intro.dart';
import 'package:runtod_app/pages/nav-user/navbar.dart';
import 'package:runtod_app/sidebar/userSidebar.dart';
import 'package:runtod_app/widget/profilePictureWidget.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({super.key});

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  late Future<UsersLoginPostResponse> loadDataUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _obscureText = true;
  bool _obscureTextCF = true;
  String imageUrl = '';
  File? profileImage;

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController fullnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmpasswordtCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();

  String displayUsername = "ผู้ใช้งาน";
  String displayFullname = "ชื่อ - สกุล";
  String displayEmail = "อีเมล";
  String displayPhone = "เบอร์โทร";
  String displayAddress = "ที่อยู่";
  String displayPass = "รหัสผ่าน";
  String displayCFpass = "ยืนยันรหัสผ่าน";

  void handleImageChanged(File image) {
    setState(() {
      profileImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDataUser = fetchUserData().then((user) {
      usernameCtl.text = user.username;
      fullnameCtl.text = user.fullname;
      emailCtl.text = user.email;
      phoneCtl.text = user.phone;
      addressCtl.text = user.address!;
      passwordCtl.text = user.password;
      confirmpasswordtCtl.text = user.password;
      return user;
    });
    usernameCtl.addListener(updateDisplayNames);
    fullnameCtl.addListener(updateDisplayNames);
    emailCtl.addListener(updateDisplayNames);
    phoneCtl.addListener(updateDisplayNames);
    addressCtl.addListener(updateDisplayNames);
    passwordCtl.addListener(updateDisplayNames);
    confirmpasswordtCtl.addListener(updateDisplayNames);
  }

  void updateDisplayNames() {
    setState(() {
      displayUsername =
          usernameCtl.text.isEmpty ? "ผู้ใช้งาน" : usernameCtl.text;
      displayFullname =
          fullnameCtl.text.isEmpty ? "ชื่อ - สกุล" : fullnameCtl.text;
      displayEmail = emailCtl.text.isEmpty ? "อีเมล" : emailCtl.text;
      displayPhone = phoneCtl.text.isEmpty ? "เบอร์โทร" : phoneCtl.text;
      displayAddress = addressCtl.text.isEmpty ? "ที่อยู่" : addressCtl.text;
      displayPass = passwordCtl.text.isEmpty ? "รหัสผ่าน" : passwordCtl.text;
      displayCFpass =
          passwordCtl.text.isEmpty ? "ยืนยันรหัสผ่าน" : passwordCtl.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    log(isPortrait ? 'Portrait' : 'Landscape');
    double customPadding = isPortrait ? 35.0 : 70.0;
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
              currentPage: 'profile',
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            FutureBuilder<UsersLoginPostResponse>(
              future: loadDataUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return ProfilePictureWidget(
                    imageUrl: snapshot.data!.imageProfile ?? '',
                    onImageChanged: (File newImage) {
                      profileImage = newImage;

                      ('New image selected: ${newImage.path}');
                    },
                  );
                } else {
                  return const Text('No data available');
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 115,
                  height: 35,
                  child: FilledButton(
                    onPressed: deleteUser,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF92A47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_rounded,
                            color: Color(0xFFFFFFFF), size: 18),
                        SizedBox(width: 3),
                        Text(
                          'ลบบัญชีผู้ใช้',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding:
                  EdgeInsets.only(left: customPadding, right: customPadding),
              child: Column(
                children: [
                  TextField(
                    controller: usernameCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: usernameCtl.text.isEmpty
                          ? "ผู้ใช้งาน"
                          : usernameCtl.text,
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: fullnameCtl,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'ชื่อ-สกุล',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'อีเมล',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneCtl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'โทรศัพท์',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon:
                          const Icon(Icons.phone_iphone, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: addressCtl,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'ที่อยู่',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon:
                          const Icon(Icons.home_rounded, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordCtl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: 'รหัสผ่าน',
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
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
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: confirmpasswordtCtl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureTextCF,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D1F),
                      hintText: "ยืนยันรหัสผ่าน",
                      hintStyle: const TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7B7B7C),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextCF
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
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
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _Save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'บันทึก',
                      style: TextStyle(
                        fontFamily: 'SukhumvitSet',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureTextCF = !_obscureTextCF;
    });
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
      Get.offAll(() => const IntroPage());
    }
  }

  Future<void> _Save() async {
    // แสดง loading indicator
    OverlayEntry overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry);

    try {
      // ตรวจสอบว่าข้อมูลว่างหรือมีช่องว่าง
      if (usernameCtl.text.trim().isEmpty ||
          fullnameCtl.text.trim().isEmpty ||
          emailCtl.text.trim().isEmpty ||
          phoneCtl.text.trim().isEmpty ||
          addressCtl.text.trim().isEmpty ||
          passwordCtl.text.trim().isEmpty ||
          confirmpasswordtCtl.text.trim().isEmpty) {
        overlayEntry.remove();
        showSnackbar(
          'สร้างบัญชีไม่สำเร็จ!',
          'กรุณาป้อนข้อมูลให้ครบทุกช่อง',
          backgroundColor: const Color(0xFFF92A47),
        );
        return;
      }

      // ตรวจสอบว่าภาพถูกเลือกหรือไม่ หากภาพจำเป็นต้องถูกอัปโหลด
      if (profileImage == null) {
        overlayEntry.remove();
        showSnackbar(
          'สร้างบัญชีไม่สำเร็จ!',
          'กรุณาเลือกภาพโปรไฟล์',
          backgroundColor: const Color(0xFFF92A47),
        );
        return;
      }

      // ตรวจสอบว่าหมายเลขโทรศัพท์มีความยาว 10 หลัก
      if (phoneCtl.text.trim().length != 10) {
        overlayEntry.remove();
        showSnackbar(
            'หมายเลขโทรศัพท์ไม่ถูกต้อง!', 'กรุณากรอกหมายเลขโทรศัพท์ 10 หลัก',
            backgroundColor: const Color(0xFFF92A47));
        return;
      }

      // ตรวจสอบว่ารหัสผ่านตรงกัน
      if (confirmpasswordtCtl.text.trim() != passwordCtl.text.trim()) {
        overlayEntry.remove();
        showSnackbar('รหัสผ่านไม่ตรงกัน!', 'กรุณากรอกรหัสผ่านให้ตรงกัน',
            backgroundColor: const Color(0xFFF92A47));
        return;
      }

      // ตรวจสอบว่าอีเมลมีเครื่องหมาย @
      if (!emailCtl.text.trim().contains('@')) {
        overlayEntry.remove();
        showSnackbar('อีเมลไม่ถูกต้อง!', 'กรุณากรอกอีเมลให้ถูกต้อง',
            backgroundColor: const Color(0xFFF92A47));
        return;
      }

      String? imageUrl;
      if (profileImage != null) {
        String phone = phoneCtl.text.trim();
        imageUrl = await uploadImageToFirebase(phone, profileImage!);
        if (imageUrl == null) {
          overlayEntry.remove();
          showSnackbar('สร้างบัญชีไม่สำเร็จ!', 'ไม่สามารถอัปโหลดรูปภาพได้!');
          return;
        }
      }
      GetStorage gs = GetStorage();
      int uid = gs.read('uid');

      var data = UsersUpdateProfilePutRequest(
        uid: uid,
        username: usernameCtl.text.trim(),
        fullname: fullnameCtl.text.trim(),
        email: emailCtl.text.trim(),
        phone: phoneCtl.text.trim(),
        address: addressCtl.text.trim(),
        password: passwordCtl.text.trim(),
        image_profile: imageUrl ?? '',
      );
      log('Sending data: ${jsonEncode(data.toJson())}');

      var response = await http.put(
        Uri.parse('$API_ENDPOINT/user/update/profile'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data.toJson()),
      );
      log('Status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      // ลบ loading indicator
      overlayEntry.remove();

      if (response.statusCode == 200) {
        showSnackbar('อัพเดตสำเร็จ!', 'ข้อมูลของคุณอัพเดตสำเร็จแล้ว',
            backgroundColor: Colors.blue);
        setState(() {});
      } else {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        String errorMessage = 'ไม่สามารถอัพเดตได้ ลองใหม่อีกครั้ง';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('error')) {
          String errorType = responseData['error'];

          if (errorType.contains('UNIQUE constraint failed')) {
            if (errorType.contains('users.username')) {
              errorMessage = 'ชื่อผู้ใช้นี้มีการใช้งานอยู่แล้ว';
            } else if (errorType.contains('users.email')) {
              errorMessage = 'อีเมลนี้มีการใช้งานอยู่แล้ว';
            } else if (errorType.contains('users.phone')) {
              errorMessage = 'หมายเลขโทรศัพท์นี้มีการใช้งานอยู่แล้ว';
            }
          }
        }

        showSnackbar('อัพเดตไม่สำเร็จ!', errorMessage,
            backgroundColor: const Color(0xFFF92A47));
      }
    } catch (e) {
      // ลบ loading indicator ในกรณีที่เกิดข้อผิดพลาด
      overlayEntry.remove();
      log('Error: $e');
      showSnackbar('อัพเดตไม่สำเร็จ!', 'ไม่สามารถลงทะเบียนได้ ลองใหม่อีกครั้ง',
          backgroundColor: const Color(0xFFF92A47));
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

  Future<String?> uploadImageToFirebase(String uid, File imageFile) async {
    try {
      // ตรวจสอบขนาดไฟล์
      final int fileSizeInBytes = await imageFile.length();
      if (fileSizeInBytes > 5 * 1024 * 1024) {
        // จำกัดขนาด 5MB
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
            .child('profile_images/$uid/$fileName');

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

  Future<void> deleteUser() async {
    OverlayEntry overlayEntry = createOverlayEntry();
    Overlay.of(context).insert(overlayEntry);

    GetStorage gs = GetStorage();
    int uid = gs.read('uid');
    overlayEntry.remove();
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
              height: 300,
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
                  const SizedBox(height: 30),
                  const Text(
                    'ยืนยันลบบัญชีผู้ใช้',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'คุณต้องการลบบัญชีผู้ใช้ใช่ไหม?',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6C6C6C),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          overlayEntry.remove();
                        },
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
                      TextButton(
                        onPressed: () async {
                          final response = await http.delete(
                            Uri.parse('$API_ENDPOINT/user/account/delete/$uid'),
                          );
                          if (response.statusCode == 200) {
                            GetStorage gs = GetStorage();
                            gs.erase();
                            Get.offAll(() => const IntroPage());
                            showSnackbar(
                                'ลบบัญชีสำเร็จ!', 'บัญชีของคุณถูกลบสำเร็จแล้ว',
                                backgroundColor: Colors.blue);
                          } else {
                            showSnackbar(
                                'ลบบัญชีไม่สำเร็จ!', 'บัญชีของคุณลบไม่ได้',
                                backgroundColor: Colors.red);
                            overlayEntry.remove();
                          }
                        },
                        child: const Text(
                          'ลบบัญชีผู้ใช้',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
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

  OverlayEntry createOverlayEntry() {
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
