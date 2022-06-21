import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pass_man/providers/ads_state.dart';
import 'package:pass_man/views/home_view.dart';
import 'package:pass_man/views/login_view.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

// ignore: constant_identifier_names
const ENCRYPTION_KEY = "20120isvba;9310291299390pvm'v";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdmobHelper.initialization();
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
        child: DynamicTheme(
          themeCollection: themeCollection,
          defaultThemeId: AppThemes.dark,
          builder: (context, themeData) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PassMan',
            theme: themeData,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  // Checking if the snapshot has any data or not
                  if (snapshot.hasData) {
                    // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                    return const HomeScreen();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  }
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return const LoginScreen();
              },
            ),
          ),
        ));
  }
}
