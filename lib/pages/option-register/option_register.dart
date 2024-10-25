import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:runtod_app/pages/option-register/rider_register.dart';
import 'package:runtod_app/pages/option-register/user_register.dart';

class OptionRegisterPage extends StatefulWidget {
  const OptionRegisterPage({super.key});

  @override
  State<OptionRegisterPage> createState() => _OptionRegisterPageState();
}

class _OptionRegisterPageState extends State<OptionRegisterPage> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return DraggableScrollableSheet(
      initialChildSize: isLandscape ? 1.00 : 0.80,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (_, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1D1D1F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
          ),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 138,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'เลือกประเภทบัญชี',
                style: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const Text(
                'คุณต้องการสร้างบัญชีประเภทไหน?',
                style: TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C6C6C),
                ),
              ),
              const SizedBox(height: 30),
              if (isLandscape)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildOptionButton(Icons.person_rounded, 'ผู้ใช้ระบบ', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserRegisterPage(),
                        ),
                      );
                    }),
                    buildOptionButton(Icons.motorcycle_rounded, 'ไรเดอร์', () {
                      Get.to(() => RiderRegisterPage());
                    }),
                  ],
                )
              else
                Column(
                  children: [
                    buildOptionButton(Icons.person_rounded, 'ผู้ใช้ระบบ', () {
                      Get.to(() => UserRegisterPage());
                    }),
                    const SizedBox(height: 30),
                    buildOptionButton(Icons.motorcycle_rounded, 'ไรเดอร์', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiderRegisterPage(),
                        ),
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 65, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'SukhumvitSet',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
