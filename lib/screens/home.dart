import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      // Test API Call
      // Provider.of<InfoProvider>(context, listen: false).getTestData();
      init = false;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: height * 2,
            ),
            buildTitleText("Dashboard" , Data.primaryTextColor, width),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: height * 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                  ],
                ),
                SizedBox(
                  height: height * 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                    buildMenuItem(Icons.ac_unit, "Ac Unit", Colors.red),
                  ],
                ),
              ],
            ),

          ]
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  InkWell buildMenuItem(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        print("Tapped $text");
      },
      child: Expanded(
        child: Container(
                color: Colors.teal,
                child: Column(
                  children: [
                    Icon(icon, color: color, size: width * 10),
                    buildBodyText(
                      text,
                      color,
                      width,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}