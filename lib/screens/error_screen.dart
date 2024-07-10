import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  ErrorScreen({super.key, this.isConnectedToInternet = true});

  static const routeName = "errorScreen";
  final double height = SizeConfig.safeBlockVertical;
  final double width = SizeConfig.safeBlockHorizontal;
  final bool isConnectedToInternet;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) async {
        // do nothing-just disable back button
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                !isConnectedToInternet ? Icons.wifi_off : Icons.error_outline,
                size: width * 15,
                color: Provider.of<InfoProvider>(context, listen: true)
                    .systemInfo
                    .iconsColor,
              ),
            ),
            SizedBox(
              height: height,
            ),
            buildCustomText(
              !isConnectedToInternet
                  ? "No Internet Connection"
                  : "An Error has occurred",
              Data.greyTextColor,
              width * 3,
              textAlign: TextAlign.center,
            ),
            !isConnectedToInternet
                ? buildCustomText(
                    "Please connect to the internet and try again.",
                    Data.greyTextColor,
                    width * 2,
                    textAlign: TextAlign.center,
                  )
                : const SizedBox(),
            SizedBox(
              height: height * 10,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: height),
                  margin:
                      EdgeInsets.symmetric(horizontal: width, vertical: height),
                  width: width * 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .primaryColor,
                  ),
                  child: Center(
                      child: buildBodyText(
                    "Retry",
                    Colors.white,
                    width,
                    fontFamily: "RobotoBold",
                  ))),
            ),
          ],
        ),
      ),
    );
  }
}
