// import 'package:yarima_wallet_pro/app/modules/auth/splash_screen.dart';
// import 'package:yarima_wallet_pro/app/modules/profile/components/biometrics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class FingerprintAuthPage extends StatefulWidget {
//   const FingerprintAuthPage({super.key});

//   @override
//   _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
// }

// class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
//   // final BiometricUtils _biometricUtils = BiometricUtils();

//   @override
//   void initState() {
//     super.initState();
//     _initializeBiometricAuth();
//   }

//   void _initializeBiometricAuth() async {
//     // Fetch biometrics enabled status from GetStorage
//     bool biometricsEnabled = await _biometricUtils.isBiometricEnabled();
//     if (biometricsEnabled) {
//       // Biometrics are enabled, start authentication
//       _authenticate();
//     } else {
//       // Biometrics are not enabled, navigate to next screen
//       _navigateToNextScreen();
//     }
//   }

//   // Method to start biometric authentication
//   void _authenticate() async {
//     // Check if biometrics are available
//     bool biometricsAvailable = await _biometricUtils.isBiometricAvailable();
//     if (!biometricsAvailable) {
//       // Biometrics are not available, navigate to next screen
//       _navigateToNextScreen();
//       return;
//     }

//     // Authenticate with biometrics
//     bool isAuthenticated = await _biometricUtils.authenticate();
//     if (isAuthenticated) {
//       // Authentication succeeded, navigate to SplashScreen
//       _navigateToNextScreen();
//     } else {
//       // Authentication failed, exit the app
//       _exitApp();
//     }
//   }

//   // Method to navigate to the next screen
//   void _navigateToNextScreen() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const SplashScreen(),
//       ),
//     );
//   }

//   // Method to exit the app
//   void _exitApp() {
//     SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox();
//   }
// }
