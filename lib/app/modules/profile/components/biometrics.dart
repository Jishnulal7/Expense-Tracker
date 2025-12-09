// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';

// class BiometricUtils {
//   final LocalAuthentication _localAuthentication = LocalAuthentication();

//   // Function to check if fingerprint authentication is available
//   Future<bool> isBiometricAvailable() async {
//     bool isAvailable = false;
//     try {
//       isAvailable = await _localAuthentication.canCheckBiometrics;
//     } catch (e) {
//       debugPrint('Error checking biometric availability: $e');
//     }
//     return isAvailable;
//   }

//   // Function to check if biometric authentication is enabled by the user
//   Future<bool> isBiometricEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('biometric_enabled') ?? false;
//   }

//   // Function to set biometric authentication enabled/disabled
//   Future<void> setBiometricEnabled(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('biometric_enabled', value);
//   }

//   // Function to authenticate with biometrics
//   Future<bool> authenticate() async {
//     bool isAuthenticated = false;
//     try {
//       isAuthenticated = await _localAuthentication.authenticate(
//         options: const AuthenticationOptions(biometricOnly: false),
//         localizedReason: 'Authenticate to access Yarima Wallet',
//       );
//     } catch (e) {
//       debugPrint('Error authenticating with biometrics: $e');
//     }
//     return isAuthenticated;
//   }
// }
