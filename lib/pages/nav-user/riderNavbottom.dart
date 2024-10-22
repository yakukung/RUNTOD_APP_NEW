import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:runtod_app/pages/raider/home/deliveryList.dart';
import 'package:runtod_app/pages/raider/home/riderHome.dart';
import 'package:runtod_app/pages/raider/home/riderProfile.dart';

class Ridernavbottom extends StatefulWidget {
  final int selectedIndex;
  const Ridernavbottom({super.key, required this.selectedIndex});

  @override
  State<Ridernavbottom> createState() => _RidernavbottomState();
}

class _RidernavbottomState extends State<Ridernavbottom> {
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
          Get.to(() => Riderhome());
          break;
        case 1:
          Get.to(() => Deliverylist());
          break;
        case 2:
          Get.to(() => Riderprofile());
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
                    offset: Offset(-4.0, 0.0),
                    child: Icon(
                      FontAwesomeIcons.clipboardList,
                      size: 23.0,
                    ),
                  ),
                  label: 'รายการที่ส่ง',
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
