import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pass_man/views/home_view.dart';
import 'package:pass_man/views/login_view.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

// ignore: constant_identifier_names
const ENCRYPTION_KEY = "20120isvba;9310291299390pvm'v";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCvkB4B2meEdsllK5n6V9wbEyOGRfix6do",
            authDomain: "passman-b55e4.firebaseapp.com",
            projectId: "passman-b55e4",
            storageBucket: "passman-b55e4.appspot.com",
            messagingSenderId: "1074258284830",
            appId: "1:1074258284830:web:c7f8537bc0cf1535bd390f",
            measurementId: "G-SXQZQRPESM"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PassMan',
        theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.purple,
            primaryColor: Colors.purple[400],
            buttonColor: Colors.pink[400],
            scaffoldBackgroundColor: Colors.white70,
            hoverColor: Colors.red[600]),
        // home:

        home: HomeScreen(),
      ),
    );
  }
}
