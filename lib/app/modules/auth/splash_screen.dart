import 'package:yarima_wallet_pro/app/data/constants/app_assets.dart';
import 'package:yarima_wallet_pro/app/modules/home/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _navigateToHome();
    super.initState();
  }

  _navigateToHome() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));
    // Navigate to home screen and remove splash screen from stack
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return HomeScreen();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(20, 22, 42, 1),
      body: Column(
        children: [
          Image.asset(
            fit: BoxFit.cover,
            AppAssets.kSplash,
            height: height,
            width: width,
          ),
        ],
      ),
    );
  }
}
