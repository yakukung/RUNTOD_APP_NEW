import 'package:flutter/material.dart';
import 'package:runtod_app/model/Response/UsersLoginPostResponse.dart';
import 'dart:ui'; // For BackdropFilter

class RiderNavbar extends StatelessWidget implements PreferredSizeWidget {
  final Future<UsersLoginPostResponse> loadDataUser;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const RiderNavbar({
    super.key,
    required this.loadDataUser,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: FutureBuilder<UsersLoginPostResponse>(
            future: loadDataUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final user = snapshot.data;
              if (user == null) {
                return const Text('No user data available');
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: ClipOval(
                        child: (user.imageProfile?.isNotEmpty ?? false) &&
                                Uri.tryParse(user.imageProfile ?? '')
                                        ?.isAbsolute ==
                                    true
                            ? Image.network(
                                user.imageProfile!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultImage();
                                },
                              )
                            : _buildDefaultImage(),
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFEAAC8B),
                        Color(0xFFE88C7D),
                        Color(0xFFEE5566),
                        Color(0xFFB56576),
                        Color(0xFF6D597A),
                        Color(0xFF355070),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomLeft,
                    ).createShader(bounds),
                    child: const Column(
                      children: [
                        Text(
                          'RANTOD',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Delivery',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
