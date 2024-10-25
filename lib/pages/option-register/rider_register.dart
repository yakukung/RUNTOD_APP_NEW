import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/model/Request/RaiderRegisterPostRequest.dart';
import 'package:runtod_app/pages/login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:runtod_app/widget/profilePictureWidget.dart';

class RiderRegisterPage extends StatefulWidget {
  const RiderRegisterPage({super.key});

  @override
  State<RiderRegisterPage> createState() => _RiderRegisterPageState();
}

class _RiderRegisterPageState extends State<RiderRegisterPage> {
  bool _obscureText = true;
  bool _obscureTextCF = true;
  String errorText = '';
  TextEditingController usernameCtl = TextEditingController();
  TextEditingController fullnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmpasswordtCtl = TextEditingController();
  TextEditingController license_plateCtl = TextEditingController();

  String imageUrl = '';
  File? profileImage;

  void handleImageChanged(File image) {
    setState(() {
      profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    log(isPortrait ? 'Portrait' : 'Landscape');
    double customPadding = isPortrait ? 35.0 : 70.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, left: 10),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => Get.to(() => const LoginPage()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: customPadding, right: customPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ลงทะเบียน',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SukhumvitSet',
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const Text(
                      'สร้างบัญชีใหม่สำหรับผู้ใช้ระบบของคุณ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C6C6C),
                        fontFamily: 'SukhumvitSet',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfilePictureWidget(
                      imageUrl: imageUrl,
                      onImageChanged: handleImageChanged,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameCtl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1D1D1F),
                        hintText: 'ชื่อผู้ใช้',
                        hintStyle: const TextStyle(
                          fontFamily: 'SukhumvitSet',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF7B7B7C),
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.white),
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
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.white),
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
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white),
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
                      controller: license_plateCtl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1D1D1F),
                        hintText: 'ทะเบียนรถ',
                        hintStyle: const TextStyle(
                          fontFamily: 'SukhumvitSet',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF7B7B7C),
                        ),
                        prefixIcon:
                            const Icon(Icons.motorcycle, color: Colors.white),
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
                      keyboardType: TextInputType.visiblePassword,
                      controller: confirmpasswordtCtl,
                      obscureText: _obscureTextCF,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1D1D1F),
                        hintText: 'ยืนยันรหัสผ่าน',
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
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _Register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF92A47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'ยืนยันการลงทะเบียน',
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

  Future<void> _Register() async {
    // แสดง loading indicator
    OverlayEntry overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry);

    try {
      // ตรวจสอบว่าข้อมูลว่างหรือมีช่องว่าง
      if (usernameCtl.text.trim().isEmpty ||
          fullnameCtl.text.trim().isEmpty ||
          emailCtl.text.trim().isEmpty ||
          phoneCtl.text.trim().isEmpty ||
          license_plateCtl.text.trim().isEmpty ||
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

      var data = RiderRegisterPostRequest(
        username: usernameCtl.text.trim(),
        fullname: fullnameCtl.text.trim(),
        email: emailCtl.text.trim(),
        phone: phoneCtl.text.trim(),
        license_plateCtl: license_plateCtl.text.trim(),
        password: passwordCtl.text.trim(),
        image_profile: imageUrl ?? '',
      );
      log('Sending data: ${jsonEncode(data.toJson())}');

      var response = await http.post(
        Uri.parse('$API_ENDPOINT/register/rider'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data.toJson()),
      );
      log('Status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      // ลบ loading indicator
      overlayEntry.remove();

      if (response.statusCode == 200) {
        showSnackbar('สร้างบัญชีสำเร็จ!', 'คุณสร้างบัญชีคุณสำเร็จแล้ว',
            backgroundColor: Colors.blue);
        Get.to(() => const LoginPage());
      } else {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        String errorMessage = 'ไม่สามารถลงทะเบียนได้ ลองใหม่อีกครั้ง';

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

        showSnackbar('สร้างบัญชีไม่สำเร็จ!', errorMessage,
            backgroundColor: const Color(0xFFF92A47));
      }
    } catch (e) {
      // ลบ loading indicator ในกรณีที่เกิดข้อผิดพลาด
      overlayEntry.remove();
      log('Error: $e');
      showSnackbar(
          'สร้างบัญชีไม่สำเร็จ!', 'ไม่สามารถลงทะเบียนได้ ลองใหม่อีกครั้ง',
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

  void _showSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
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
}
