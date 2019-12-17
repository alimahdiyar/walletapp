import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:walletapp/helper/exceptions.dart';
import 'package:walletapp/helper/app_config.dart';
import 'package:walletapp/models/user_profile.dart';


class UserProfileProvider with ChangeNotifier {
  String _authToken;
  UserProfile userProfile = null;

  set authToken(String value) {
    _authToken = value;
    notifyListeners();
  }


  Future<void> fetchAndSetUserProfile() async {
    try {
      print("fetchAndSetUserProfile");

      final response = await http.get(
          AppConfig.hostUrl + '/api/v1/user-profile/retrieve-data/?format=json', headers: {
            'Authorization': 'token ' + _authToken
          });
      userProfile =
          UserProfile.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      print("fetchAndSetBill response");


      //hardcoded
//      await Future.delayed(const Duration(seconds: 1), () =>
//      userProfile =
//          UserProfile.fromJson(json.decode('{"phone_number":"09171164374","user_tags":[{"title":"خوراکی","user_tag_transactions":[{"reason":"ساندویچ ناهار","amount":15000,"is_income":false}]},{"title":"حقوق","user_tag_transactions":[{"reason":"حقوق ماهیانه","amount":1000000,"is_income":true}]},{"title":"لباس","user_tag_transactions":[{"reason":"خرید کفش","amount":300000,"is_income":false}]}]}'))
//      );

      notifyListeners();
    } on SocketException catch (e) {
//      print("hiiii");
      throw FetchDataException(e.toString());
    }
  }

}
