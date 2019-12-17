import 'package:walletapp/providers/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/user_profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, UserProfileProvider>(
          create: (_) => UserProfileProvider(),
          update: (ctx, auth, userProfile) =>
              userProfile..authToken = auth.token,
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'walletapp',
          home: auth.isAuth ? UserProfileScreen() : AuthScreen(),
        ),
      ),
    );
  }
}
