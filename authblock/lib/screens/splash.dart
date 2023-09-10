//some time Firebase will takes some time to load token/data from mobile device
//so it will show a glitch of AuthScreen for some second instaed of Main Conetent Screen
//so the batter way is to use splash screen while recources/token loading

import 'package:flutter/material.dart';

//we show that screen when user login
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splash'),
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
