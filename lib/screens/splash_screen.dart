import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/screens/login_screen.dart';
import 'package:flutter/material.dart';

const int splashPageVisibilityTime = 2000;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = "splashScreen";

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late double height;
  late double width;
  late AnimationController _controller;

  @override
  void initState() {
    _navigateToHomeScreen();

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
        lowerBound: 0,
        upperBound: 10);
    _controller.reverse(from: 10);
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //initialize size config at the very beginning
    SizeConfig().init(context);
    height = SizeConfig.safeBlockVertical;
    width = SizeConfig.safeBlockHorizontal;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.value <= 8
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: height * _controller.value,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          "assets/splash.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        height: height * 4,
                      ),
                      Center(
                        child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 6,
                            fontFamily: "RobotoRegular",
                            color: Data.darkTextColor,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText('EPOS System',
                                  speed: const Duration(milliseconds: 60)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 10,
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      "assets/splash.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToHomeScreen() async {
    Timer(
      const Duration(milliseconds: splashPageVisibilityTime),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    );
  }
}
