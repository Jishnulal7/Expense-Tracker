import 'package:yarima_wallet_pro/app/modules/profile/components/exports.dart';

class Mail {
  String email = 'pamacomkb@gmail.com';
  String subject = 'Feedback:Yarima Wallet';
  String body = 'Hello, Iam using Yarima Wallet';

  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      await launchUrlString(emailUri.toString());
    } catch (e) {
      throw 'Could not launch $emailUri';
    }
  }
}
