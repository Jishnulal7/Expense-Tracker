import 'package:yarima_wallet_pro/app/modules/add/exports.dart';
import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart'
    as upgrade;
import 'package:url_launcher/url_launcher.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key, required this.packageInfo});

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        packageInfo.appName.toUpperCase(),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Version: ${packageInfo.version}',
        textAlign: TextAlign.center,
      ),
      actions: [
        buildActionButtons(context),
      ],
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () async {
            try {
              await _checkAndroidUpdate(context);
            } catch (e) {
              debugPrint('Error checking for updates: $e');
              _showFallbackUpdateDialog(context);
            }
          },
          child: const Text('Check for Updates'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _checkAndroidUpdate(BuildContext context) async {
    try {
      upgrade.InAppUpdateManager manager = upgrade.InAppUpdateManager();
      upgrade.AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) {
        _showFallbackUpdateDialog(context);
        return;
      }

      if (appUpdateInfo.updateAvailability ==
          upgrade.UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.immediateAllowed) {
          String? message = await manager.startAnUpdate(
              type: upgrade.AppUpdateType.immediate);
          debugPrint(message ?? '');
        } else if (appUpdateInfo.flexibleAllowed) {
          String? message =
              await manager.startAnUpdate(type: upgrade.AppUpdateType.flexible);
          debugPrint(message ?? '');
        } else {
          _showUpdateDialog(context,
              'https://play.google.com/store/apps/details?id=${packageInfo.packageName}');
        }
      } else {
        const CustomToast(message: "No updates available").showToast(context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error in Android update check: $e');
      _showFallbackUpdateDialog(context);
    }
  }

  void _showUpdateDialog(BuildContext context, String storeLink) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text('A new version of the app is available.'),
          actions: [
            TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(storeLink))) {
                  await launchUrl(Uri.parse(storeLink));
                } else {
                  throw 'Could not launch $storeLink';
                }
              },
              child: const Text('Update Now'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
          ],
        );
      },
    );
  }

  void _showFallbackUpdateDialog(BuildContext context) {
    String storeLink =
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Check for Updates'),
          content: const Text(
              'Would you like to check for updates in the Play Store?'),
          actions: [
            TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(storeLink))) {
                  await launchUrl(Uri.parse(storeLink));
                } else {
                  throw 'Could not launch $storeLink';
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
