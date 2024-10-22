import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runtod_app/pages/user/home/homeUser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:runtod_app/pages/user/home/profileUser.dart';
import 'package:runtod_app/pages/user/home/sendUser.dart';
import 'package:runtod_app/pages/user/home/statusUser.dart';

class NavBottom extends StatefulWidget {
  final int selectedIndex;

  const NavBottom({super.key, required this.selectedIndex});

  @override
  State<NavBottom> createState() => _NavBottomState();
}

class _NavBottomState extends State<NavBottom> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Get.to(() => HomeUserPage());
          break;
        case 1:
          Get.to(() => SenduserPage());
          break;
        case 2:
          Get.to(() => StatususerPage());
          break;
        case 3:
          Get.to(() => ProfileUserPage());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double customPadding;
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      customPadding = 115.0;
    } else {
      customPadding = 100.0;
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
        child: Container(
          height: customPadding,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Theme(
            data: ThemeData(
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedLabelStyle: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.2),
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.house_rounded,
                    size: 30.0,
                  ),
                  label: 'หน้าหลัก',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(-4.0, 0.0), // ขยับไอคอนในแนวแกน X -1
                    child: Icon(
                      FontAwesomeIcons.boxOpen,
                      size: 23.0,
                    ),
                  ),
                  label: 'ส่งสินค้า',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.local_shipping_rounded,
                    size: 30.0,
                  ),
                  label: 'สถานะสินค้า',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    size: 30.0,
                  ),
                  label: 'โปรไฟล์',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
