import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class AppLike extends StatelessWidget {
  const AppLike({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Like Yarima Wallet',
        textAlign: TextAlign.center,
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How do you like this app?',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            'If you like Yarima Wallet, please consider rating it 5-star to support its development',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(height: 10),
        ],
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
            final InAppReview inAppReview = InAppReview.instance;

            if (await inAppReview.isAvailable()) {
              inAppReview.requestReview();
            } else {
              // Fall back to opening the Play Store if in-app review is not available
              const url =
                  'https://play.google.com/store/apps/details?id=com.pamaco.wallet';
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              } else {
                throw 'Could not launch $url';
              }
            }
          },
          child: const Text('Rate it'),
        ),
        TextButton(
          onPressed: () {
            const url =
                'https://play.google.com/store/apps/details?id=com.pamaco.wallet';
            Share.share('Check out this awesome app: $url');
          },
          child: const Text('Share it'),
        ),
      ],
    );
  }
}
