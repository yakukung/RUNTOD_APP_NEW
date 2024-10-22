import 'package:runtod_app/animations/fade_in.dart';
import 'package:runtod_app/animations/opacity_in.dart';
import 'package:runtod_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _moveAnimationController;
  late Animation<Offset> _moveAnimation;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/video/delivery.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoController.setVolume(0);
          _videoController.play();
          _videoController.setLooping(true);
        });
      });

    _moveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _moveAnimationController,
      curve: Curves.elasticInOut,
    ));

    _moveAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _moveAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _moveAnimationController.forward();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _moveAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _moveAnimationController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Transform.scale(
                scale: 1.2,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: MediaQuery.sizeOf(context).height * 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: isPortrait ? 30 : 80,
            top: isPortrait ? 100 : 90,
            right: isPortrait ? 40 : 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OpacityIn(
                  delay: 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยินดีต้อนรับ',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF7B7B7C),
                          )),
                      Text('RUNTOD DELIVERY',
                          style: TextStyle(
                              fontFamily: 'SukhumvitSet',
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color(0xFFFFFFFF))),
                      Text('( รันทด เดลิเวอรี่ )',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFFFFFFF),
                          )),
                      SizedBox(height: 8),
                      Text('ลำบากลำบนก็จะส่งให้ถึงมือคุณ',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SlideTransition(
                  position: _moveAnimation,
                  child: FadeInAnimation(
                    delay: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF92A47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      label: const Text('ไปกันเล๊ย!',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
