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
import 'package:runtod_app/pages/user/home/searchNumberUser.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  late Future<UsersLoginPostResponse> loadDataUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        File? newImage = await _pickImage();
                        if (newImage != null) {
                          setState(() {
                            profileImage = newImage;
                          });
                          print('New image selected: ${newImage.path}');
                        }
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 80,
                            color: Colors.grey,
                          ),
                          
                        ),
                        
                      ),
                    ),
                    const SizedBox(
                        width: 10), // เพิ่มช่องว่างระหว่างรูปภาพกับฟิลด์ชื่อ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ฟิลด์เก็บชื่อ
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อสินค้า',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  10), // เพิ่มระยะห่างระหว่างฟิลด์ชื่อและฟิลด์รายละเอียด
                          // ฟิลด์เก็บรายละเอียด
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
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        File? newImage = await _pickImage();
                        if (newImage != null) {
                          setState(() {
                            profileImage = newImage;
                          });
                          print('New image selected: ${newImage.path}');
                        }
                      },
                      child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'ภาพประกอบสถานะ',
                            style: TextStyle(
                              fontSize: 15, // ขนาดข้อความ
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 16),
                    Text('ผู้รับ',
                        style: TextStyle(
                          fontSize: 30, // ขนาดข้อความ
                          color: Color.fromARGB(255, 255, 255, 255),
                        )),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => Searchnumberuser());
                      },
                      child: Container(
                        width: 300,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // ปุ่มบันทึกข้อมูล
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // เรียกฟังก์ชันเพื่อบันทึกข้อมูล
                      _saveData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // กำหนดสีพื้นหลังเป็นสีเขียว
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

// ฟังก์ชันสำหรับบันทึกข้อมูล
  void _saveData() {
    String name = nameController.text;
    String description = descriptionController.text;

    if (profileImage != null) {
      // ในที่นี้คุณสามารถบันทึกข้อมูล name, description และ profileImage ตามที่ต้องการ
      print('ชื่อสินค้า: $name');
      print('รายละเอียดสินค้า: $description');
      print('รูปภาพ: ${profileImage!.path}');

      // ตัวอย่างการบันทึกข้อมูลไปยังเซิร์ฟเวอร์หรือฐานข้อมูล
      // await saveToDatabase(name, description, profileImage!);

      // แสดงข้อความยืนยันว่าบันทึกสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
      );
    } else {
      // แสดงข้อความเตือนเมื่อไม่มีรูปภาพ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกภาพประกอบ')),
      );
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
      return File(pickedFile.path);
    }
    return null;
  }
}
