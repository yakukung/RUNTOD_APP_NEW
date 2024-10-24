import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'package:http/http.dart' as http;
import 'package:runtod_app/config/internal_config.dart';
import 'package:runtod_app/pages/intro.dart';
import 'dart:developer';

import 'package:runtod_app/pages/user/home/sendUser.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  late Future<UsersLoginPostResponse> loadDataUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? productImage;
  File? imageStatus;
  String imageUrlproduct = '';
  String imageUrlStatus = '';
  String phoneCtl1 = '';
  final ImagePicker _picker = ImagePicker();
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
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
                SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GestureDetector for productImage
                    GestureDetector(
                      onTap: () => _selectImageSource(context, true),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: productImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  productImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อสินค้า',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'รายละเอียดสินค้า',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // เรียกฟังก์ชันบันทึกข้อมูลก่อน
                      await _Save();

                      // หลังจากบันทึกข้อมูลเสร็จแล้ว, ไปยังหน้า senduser โดยใช้ Get
                      Get.to(SenduserPage()); // เปลี่ยนหน้าโดยใช้ Get.to()
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('บันทึกข้อมูล'),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  void _selectImageSource(BuildContext context, bool isProductImage) async {
    final pickedSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (pickedSource != null) {
      File? newImage = await _pickImage(pickedSource);
      if (newImage != null) {
        setState(() {
          if (isProductImage) {
            productImage = newImage; // Set productImage
          }
        });
        print('New image selected: ${newImage.path}');
      }
    }
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

      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/$uid/$fileName'); // แก้ไขที่อยู่ให้เหมาะสม

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
  }

  Future<void> _Save() async {
    try {
      if (nameController.text.trim().isEmpty ||
          descriptionController.text.trim().isEmpty ||
          productImage == null) {
        showSnackbar('สร้างรายการไม่สำเร็จ!', 'กรุณาป้อนข้อมูลให้ครบทุกช่อง',
            backgroundColor: const Color(0xFFF92A47));
        return;
      }

      String? imageUrlproduct =
          await uploadImageToFirebase(phoneCtl1, productImage!);
      if (imageUrlproduct == null) {
        showSnackbar(
            'สร้างรายการไม่สำเร็จ!', 'ไม่สามารถอัปโหลดรูปภาพสินค้าได้!');
        return;
      }

      // String? imageStatusUrl = await uploadImageToFirebase(phoneCtl1, imageStatus!);
      // if (imageStatusUrl == null) {
      //   showSnackbar('สร้างรายการไม่สำเร็จ!', 'ไม่สามารถอัปโหลดรูปภาพสถานะได้!');
      //   return;
      // }

      GetStorage gs = GetStorage();
      String senderId = gs.read('uid')?.toString() ?? '';
      if (senderId.isEmpty) {
        showSnackbar('เกิดข้อผิดพลาด!', 'ไม่พบ ID ผู้ส่ง');
        return;
      }

      var data = {
        "sender_id": senderId,
        "name_product": nameController.text.trim(),
        "detail_product": descriptionController.text.trim(),
        "image_product": imageUrlproduct,
      };

      log('Sending data: ${jsonEncode(data)}');
      var response = await http.post(
        Uri.parse('$API_ENDPOINT/user/orders/products/$senderId'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data),
      );

      log('Status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        showSnackbar('สร้างรายการสำเร็จ!', 'ข้อมูลของคุณได้ถูกบันทึกแล้ว',
            backgroundColor: Colors.blue);
        setState(() {});
      } else {
        log('Error response: ${response.body}');
        showSnackbar(
            'สร้างรายการไม่สำเร็จ!', 'ไม่สามารถบันทึกข้อมูลได้ ลองใหม่อีกครั้ง',
            backgroundColor: const Color(0xFFF92A47));
      }
    } catch (e) {
      log('Error: $e');
      showSnackbar(
          'สร้างรายการไม่สำเร็จ!', 'ไม่สามารถบันทึกข้อมูลได้ ลองใหม่อีกครั้ง',
          backgroundColor: const Color(0xFFF92A47));
    }
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
      UsersLoginPostResponse userData =
          UsersLoginPostResponse.fromJson(responseData);

      // กำหนดค่าให้กับ phoneCtl1
      phoneCtl1 = userData.phone;

      return userData;
    } else {
      await _clearStorageAndNavigate();
      throw Exception('Failed to load user data: ${response.reasonPhrase}');
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

  Future<void> _clearStorageAndNavigate() async {
    try {
      GetStorage gs = GetStorage();
      await gs.erase();
    } catch (e) {
      print('Error clearing storage: $e');
    } finally {
      Get.offAll(() => IntroPage());
    }
  }

  // Future<File?> _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     return File(pickedFile.path);
  //   }
  //   return null;
  // }
}
