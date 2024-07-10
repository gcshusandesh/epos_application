import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epos_application/screens/error_screen.dart';
import 'package:flutter/material.dart';

class ExtraProvider extends ChangeNotifier {
  bool obscureText = true;

  void changeObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }

  // assume by default device is connected to the Internet
  bool isConnectedToInternet = true;

  Future<void> checkInternetConnection({required BuildContext context}) async {
    print("checking internet");
    // check if the user is connected to the internet
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Device is not Connected to Internet
      isConnectedToInternet = false;
      if (context.mounted) {
        // Navigate to Error Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    isConnectedToInternet: isConnectedToInternet,
                  )),
        );
      }
    } else {
      isConnectedToInternet = true;
    }
    print("Internet status $isConnectedToInternet");
  }
}
