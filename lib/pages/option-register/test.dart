import 'dart:io';
import 'package:flutter/material.dart';
import 'package:runtod_app/widget/profilePictureWidget.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String imageUrl = ''; // สถานะภาพโปรไฟล์ (เริ่มต้นเป็นว่าง)

  void _updateImage(File image) {
    // ฟังก์ชันที่จะถูกเรียกเมื่อมีการเปลี่ยนแปลงภาพ
    setState(() {
      imageUrl = image.path; // อัปเดต imageUrl ด้วย path ของภาพใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfilePictureWidget(
              imageUrl: imageUrl, // ส่ง imageUrl ไปที่ ProfilePictureWidget
              onImageChanged:
                  _updateImage, // ส่งฟังก์ชันสำหรับจัดการการเปลี่ยนแปลงภาพ
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่าง widget
            Text('Profile Picture Update Example'), // ข้อความตัวอย่าง
          ],
        ),
      ),
    );
  }
}
