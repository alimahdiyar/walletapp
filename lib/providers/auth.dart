import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Auth with ChangeNotifier {
  String _token = "892e5ccee88e85a3d3034a3c1ea2836f782c6b5d"; //Debugging
  bool get isAuth {
    return token != null;
  }

  String get token {
      return _token;
  }


  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyC13spCwP_f_SalxEbkB-wjedoF8iYENlQ';
    try {
//      final response = await http.post(
//        url,
//        body: json.encode(
//          {
//            'email': email,
//            'password': password,
//            'returnSecureToken': true,
//          },
//        ),
//      );
//      final responseData = json.decode(response.body);
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      _token = "set new token here";
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

}
