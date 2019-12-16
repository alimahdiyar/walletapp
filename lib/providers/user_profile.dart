import 'package:flutter/widgets.dart';


class UserProfile with ChangeNotifier {
  String _authToken;

  set authToken(String value) {
    _authToken = value;
    notifyListeners();
  }


}
