import 'package:authblock/screens/auth.dart';
import 'package:authblock/screens/chat.dart';
import 'package:authblock/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(225, 63, 17, 177),
        ),
      ),
      //StreamBuilder() capable to produce multiple value over the time
      //show Authscreen if user not login or signup
      //or show ChatScreen if user have token or user login before with help of snashot
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        //authStateChange() method return Stream
        //firebase emit new value whenever auth is changes
        builder: ((context, snapshot) {
          //if we are Still wating for firebase to access token from device
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          //snashot give this emited value
          //firebase not emit any data if we dont have login/token
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        }),
      ),
    );
  }
}
