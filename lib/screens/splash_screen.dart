import 'dart:async';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/screens/home.dart';
import 'package:flutter/material.dart';

const int splashPageVisibilityTime = 1000;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = "splashScreen";
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateToHomeScreen();
  }

  late double height;
  late double width;
  bool init = true;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      if (init) {
        init = false;
        isSwitched = true;
        SizeConfig().init(context);
        height = SizeConfig.safeBlockVertical;
        width = SizeConfig.safeBlockHorizontal;
        // Locale myLocale = Localizations.localeOf(context);
        // String lc = myLocale.languageCode;
      }
    }
  }

  bool isSwitched = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Data.primaryBlue,
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width:width * 35,
                  child: buildCustomText("Shusandesh GC", Colors.white, 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToHomeScreen() async {
    Timer(
      const Duration(milliseconds: splashPageVisibilityTime),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage(title: "My Home Page")),
            );
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //     HomePage.routeName, (Route<dynamic> route) => false);
      },
    );
  }
}
