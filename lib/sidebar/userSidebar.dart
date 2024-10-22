import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:runtod_app/pages/intro.dart';
import 'package:runtod_app/pages/user/home/profileUser.dart';
import 'package:runtod_app/pages/user/home/homeUser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:runtod_app/pages/user/home/sendUser.dart';
import 'package:runtod_app/pages/user/home/statusUser.dart';

class CustomerSidebar extends StatelessWidget {
  final String imageUrl;
  final String fullname;
  final int uid;
  final String currentPage;

  const CustomerSidebar({
    super.key,
    required this.imageUrl,
    required this.fullname,
    required this.uid,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double customPadding = isPortrait ? 20.0 : 60.0;

    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.7,
      heightFactor: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF5F5F7).withOpacity(0.85),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.black,
                      iconSize: 50,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: customPadding, top: 20, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipOval(
                              child: imageUrl.isNotEmpty &&
                                      Uri.tryParse(imageUrl)?.isAbsolute == true
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return _buildDefaultImage();
                                      },
                                    )
                                  : _buildDefaultImage(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fullname,
                        style: const TextStyle(
                          fontFamily: 'SukhumvitSet',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMenuItem(
                  context,
                  customPadding: customPadding,
                  icon: Icons.house_rounded,
                  text: 'หน้าหลัก',
                  page: 'home',
                  onTap: () {
                    Get.to(() => HomeUserPage());
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuItem(
                  context,
                  customPadding: customPadding,
                  icon: Icons.person_rounded,
                  text: 'ข้อมูลส่วนตัว',
                  page: 'profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => ProfileUserPage());
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuItem(
                  context,
                  customPadding: customPadding,
                  icon: FontAwesomeIcons.boxOpen,
                  text: 'ส่งสินค้า',
                  page: 'send',
                  onTap: () {
                    Get.to(() => SenduserPage());
                  },
                  isTransformed: true,
                ),
                const SizedBox(height: 10),
                _buildMenuItem(
                  context,
                  customPadding: customPadding,
                  icon: Icons.local_shipping_rounded,
                  text: 'สถานะการส่ง',
                  page: 'status',
                  onTap: () {
                    Get.to(() => StatususerPage());
                  },
                ),
                const SizedBox(height: 50),
                _buildMenuItem(
                  context,
                  customPadding: customPadding,
                  icon: Icons.logout_rounded,
                  text: 'ออกจากระบบ',
                  page: 'logout', // เพิ่มค่า page
                  onTap: () {
                    _showLogoutConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required double customPadding,
      required IconData icon,
      required String text,
      required String page,
      required VoidCallback onTap,
      bool isTransformed = false}) {
    // Added parameter for transformation
    bool isSelected = currentPage == page;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: customPadding, right: customPadding),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isTransformed)
                Transform.translate(
                  offset: Offset(-4.0, 0.0),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.black : Colors.black,
                    size: 38,
                  ),
                )
              else
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.black,
                  size: 38,
                ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ClipOval(
          child: Image.asset(
            'assets/icon/zen.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
              height: 280,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ยืนยันออกจากระบบ',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'คุณต้องการออกจากระบบใช่ไหม?',
                    style: TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          GetStorage gs = GetStorage();
                          gs.erase();
                          Get.offAll(() => IntroPage());
                        },
                        child: const Text(
                          'ออกจากระบบ',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF92A47),
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
}
