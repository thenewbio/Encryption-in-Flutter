import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pass_man/views/home_view.dart';

class FingerPrint extends StatefulWidget {
  const FingerPrint({Key? key}) : super(key: key);

  @override
  State<FingerPrint> createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {
  static final _auth = LocalAuthentication();
  late bool check;
  late List<BiometricType> available;
  String authorize = "Not authorized";

  static Future<bool> hasBioMetric() async {
    try {
      return _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
      return false;
    }
    // if (!mounted) return;
    // setState(() {
    //   check = canCheck;
    // });
  }

  Future<void> getAvailable() async {
    late List<BiometricType> availableBio;
    try {
      availableBio = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    setState(() {
      available = availableBio;
    });
  }

  static Future<bool> _authenticate() async {
    final isAvailable = await hasBioMetric();
    if (!isAvailable) return false;
    try {
      return await _auth.authenticate(
        localizedReason: "Scan your finger to continue",
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
      return false;
    }
  }

  @override
  void initState() {
    getAvailable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FingerPrint'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('For Security Purpose, You need to scan your Fingerprint'),
          Center(
              child: ElevatedButton(
            onPressed: () async {
              final isAuth = await _authenticate();
              if (isAuth) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()));
              }
            },
            child: const Icon(Icons.fingerprint),
          )),
        ],
      ),
    );
  }
}
