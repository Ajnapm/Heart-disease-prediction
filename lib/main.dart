import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
 //import 'package:chat.dart';
// import '/../../recommend.dart';
//import '/../../chat.dart';
import '/../../screens/app/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCqKqm5rMVVzOWLEhcwXYB9KiKrh6YrEz8",
      appId: "1:358903017804:android:c916a813dd789c209adfe9",
      messagingSenderId: "358903017804",
      projectId: "sign-main",
    ),
  );
  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
