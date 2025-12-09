import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:yarima_wallet_pro/app/data/helpers/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class SimpleTransferList extends StatelessWidget {
  final String fromAccount;
  final String toAccount;
  final double amount;
  final Function()? onDelete;

  const SimpleTransferList({
    super.key,
    required this.fromAccount,
    required this.amount,
    this.onDelete,
    required this.toAccount,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Image.asset(
                        CustomIcons().getImagePathForAccounts(fromAccount),
                        width: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        fromAccount,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                    ),
                    Flexible(
                      child: Image.asset(
                        CustomIcons().getImagePathForAccounts(toAccount),
                        width: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        toAccount,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$currencySymbol ${amount.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 13, color: AppColor.kPrimary),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
