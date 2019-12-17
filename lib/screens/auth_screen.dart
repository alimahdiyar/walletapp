import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletapp/helper/app_config.dart';
import 'package:walletapp/helper/exceptions.dart';

import 'package:http/http.dart' as http;

import '../providers/auth.dart';


enum AuthMode { SendCode, VerifyCode }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _authMode = AuthMode.SendCode;
  bool _isLoading = false;
  Map<String, String> _authData = {
    'phone_number': '',
    'code': '',
  };

  final GlobalKey<FormState> _formKey = GlobalKey();

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
//        title: Text('خطا'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('تایید'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    print(_authData);
    if(_authMode == AuthMode.SendCode){
      final url =
          AppConfig.hostUrl + '/api/v1/user-profile/send-code/?format=json';

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'phone_number': _authData['phone_number']
            },
          ),
        );
        final responseData = json.decode(response.body);
        if (responseData['detail'] == 'Code sent') {
          _showAlertDialog('کد تایید (برای دیباگ): ' + responseData['code']);
          setState(() {
            _authMode = AuthMode.VerifyCode;
          });
        } else if(responseData['wait'] != null) {
          _showAlertDialog('لطفا ' + double.parse(responseData['wait']).round().toString() + ' ثانیه دیگر تلاش کنید');
        } else {
          _showAlertDialog('لطفا ورودی خود را کنترل کنید');
        }

      } on HttpException catch (error) {
        var errorMessage = 'خطا در ارتباط با سرور';
        _showAlertDialog(errorMessage);
      }

    } else {
      final url =
          AppConfig.hostUrl + '/api/v1/user-profile/verify-phone/?format=json';

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'phone_number': _authData['phone_number'],
              'code': _authData['code']
            },
          ),
        );
        final responseData = json.decode(response.body);
        print(responseData);


        if (responseData['token'] != null) {
          final _token = responseData['token'];
          Provider.of<Auth>(context, listen: false).token = _token;
          final prefs = await SharedPreferences.getInstance();
          final userData = json.encode(
            {
              'token': _token,
            },
          );
          prefs.setString('userData', userData);
        } else if (responseData['detail'] == 'Invalid verification code') {
          _showAlertDialog('لطفا کد معتبر وارد کنید');
        } else {
          _showAlertDialog('لطفا ورودی خود را کنترل کنید');
        }


      } on HttpException catch (error) {
        var errorMessage = 'خطا در ارتباط با سرور';
        _showAlertDialog(errorMessage);
      }

    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    if(_authMode == AuthMode.SendCode)
                      TextFormField(
                        decoration: InputDecoration(labelText: 'شماره همراه'),
                        validator: (value) {
                          Pattern pattern =
                              r'^(\+98|0)?9\d{9}$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(value))
                            return 'لطفا یک شماره معتبر وارد کنید';
                          else
                            return null;
                        },
                        onSaved: (value) {
                          _authData['phone_number'] = value;
                        },
                      )
                    else
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _authMode = AuthMode.SendCode;
                              });
                            },
                            child: Text('تغییر شماره ' + _authData['phone_number']),
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'کد تایید'),
                            validator: (value) {
                              if (value.isEmpty || value.length != 4) {
                                return 'لطفا یک کد معتبر وارد کنید';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['code'] = value;
                            },
                          ),
                        ],
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: RaisedButton(
                        child:
                        Text('تایید'),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).primaryTextTheme.button.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
