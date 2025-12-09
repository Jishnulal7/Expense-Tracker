import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';
import 'package:yarima_wallet_pro/app/modules/profile/components/app_version.dart';
import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/profile/components/theme_selector.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/to_do_screen.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool darkMode = false;
  bool isLock = false;
  bool isAttendance = false;
  String appVersion = '';

  // final BiometricUtils _biometricUtils = BiometricUtils();
  String currencyName = '';
  String currencySymbol = '';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  // Future<void> toggleAppLock(bool value) async {
  //   bool isBiometricAvailable = await _biometricUtils.isBiometricAvailable();
  //   if (isBiometricAvailable) {
  //     if (value) {
  //       // Only authenticate when enabling the lock
  //       bool isAuthenticated = await _biometricUtils.authenticate();
  //       if (isAuthenticated) {
  //         await _biometricUtils.setBiometricEnabled(true);
  //         setState(() {
  //           isLock = true;
  //         });
  //       } else {
  //         // Authentication failed, don't enable the lock
  //         setState(() {
  //           isLock = false;
  //         });
  //       }
  //     } else {
  //       // Disable the lock without requiring authentication
  //       await _biometricUtils.setBiometricEnabled(false);
  //       setState(() {
  //         isLock = false;
  //       });
  //     }
  //   } else {
  //     debugPrint('Biometric authentication not available');
  //     setState(() {
  //       isLock = false;
  //     });
  //     // Show a message to the user that biometric authentication is not available
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //               'Biometric authentication is not available on this device.'),
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currencyName = prefs.getString('currency_name') ?? 'USD';
      currencySymbol = prefs.getString('currency_symbol') ?? '\$';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSectionTitle('General Settings'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSelectionPage(),
                      ),
                    );
                  },
                ),
                // _buildSettingsTile(
                //   icon: Icons.lock_outline,
                //   title: 'App-lock',
                //   trailing: CustomSwitch(
                //     isSwitchOn: isLock,
                //     onToggle: (value) => toggleAppLock(value),
                //   ),
                // ),
                _buildSettingsTile(
                  icon: Icons.currency_exchange,
                  title: 'Currency',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                _buildSettingsTile(
                  icon: Icons.list_alt_outlined,
                  title: 'To-Do',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodoScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('App Information'),
              _buildSettingsCard([
                // _buildSettingsTile(
                //   icon: Icons.save_outlined,
                //   title: 'Backup data',
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const BackupScreen(),
                //     ),
                //   ),
                // ),
                _buildSettingsTile(
                  icon: Icons.thumb_up_outlined,
                  title: 'Rate Our App',
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const AppLike(),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.mail_outline,
                  title: 'Feedback',
                  onTap: () => _showFeedbackDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.upgrade_outlined,
                  title: 'Check for Updates',
                  onTap: () async {
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AppVersion(packageInfo: packageInfo);
                      },
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      color: AppColor.kGrayscale40,
    );
  }

  ListTile buildSettingsTile(BuildContext context) {
    return ListTile(
      onTap: () {
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        } catch (e) {
          debugPrint('Error navigating to SettingsPage: $e');
        }
      },
      leading: Icon(
        Icons.settings_outlined,
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('Settings'),
      trailing: const Icon(Icons.arrow_right_outlined),
    );
  }

  // ListTile buildAppLockTile() {
  //   return ListTile(
  //     leading: const Icon(Icons.lock_outline),
  //     title: const Text('App-lock'),
  //     trailing: CustomSwitch(
  //       isSwitchOn: isLock,
  //       onToggle: toggleAppLock,
  //     ),
  //   );
  // }

  ListTile buildProVersionTile() {
    return ListTile(
      leading: const Icon(Icons.star_border_purple500_outlined),
      title: const Text('Pro version'),
      trailing: const Icon(Icons.arrow_right_outlined),
      onTap: () {
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return ConfirmationDialog(
        //       title: 'Pro version',
        //       content:
        //           'You can support development by purchasing the Yarima Wallet pro version, which has additional features features.',
        //       onCancel: () => Navigator.of(context).pop(false),
        //       onConfirm: () => launchUrlString(
        //           'https://play.google.com/store/apps/details?id=com.pamaco.wallet'),
        //       confirmButtonText: 'Go to Playstore',
        //       cancelButtonText: 'Close',
        //     );
        //   },
        // );
        const CustomToast(message: 'Coming Soon 😎').showToast(context);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    if (title == 'Currency') {
      return Consumer<CurrencyNotifier>(
        builder: (context, currencyNotifier, child) {
          return ListTile(
            leading: Icon(icon),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: DropdownButton<String>(
              value: currencyNotifier.currencyName,
              items: currencyNotifier.availableCurrencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency['name'],
                  child: Text('${currency['name']} (${currency['symbol']})'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final selectedCurrency = currencyNotifier.availableCurrencies
                      .firstWhere((currency) => currency['name'] == newValue);

                  currencyNotifier.updateCurrency(
                    selectedCurrency['name']!,
                    selectedCurrency['symbol']!,
                  );
                }
              },
            ),
            onTap: onTap,
          );
        },
      );
    }
    return ListTile(
      leading: Icon(
        icon,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        content:
            'Your feedback matters! Help us improve Yarima Wallet by sharing your thoughts.',
        title: 'Send feedback',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          Navigator.of(context).pop();
          // Implement email sending logic here
        },
        confirmButtonText: 'Send mail',
        cancelButtonText: 'Cancel',
      ),
    );
  }
}
