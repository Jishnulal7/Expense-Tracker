import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class OpeningBalanceWidget extends StatelessWidget {
  final double accountBalance;
  const OpeningBalanceWidget({
    super.key,
    required this.accountBalance,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    var style = TextStyle(
      color: ColorHelper().darkorWhite(context),
      fontSize: 15,
    );
    var bold = TextStyle(
      color: ColorHelper().darkorWhite(context),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Cash : ', style: style),
          TextSpan(
              text: '$currencySymbol ${accountBalance.toStringAsFixed(1)}',
              style: bold)
        ]),
      ),
    );
  }
}
