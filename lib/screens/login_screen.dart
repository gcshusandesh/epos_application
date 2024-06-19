import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';

import '../components/size_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  bool init = true;
  late double height;
  late double width;
  @override
  void didChangeDependencies() {
    if(init){
    //initialize size config at the very beginning
    SizeConfig().init(context);
    height = SizeConfig.safeBlockVertical;
    width = SizeConfig.safeBlockHorizontal;
    super.didChangeDependencies();
    init = false;

    }
  }


  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        buildImage("assets/splash.png", 150, 150),
        buildBodyText("Please enter your credentials to access the EPOS system.", Data.lightGreyTextColor, width),
      ],
    );
  }
}
