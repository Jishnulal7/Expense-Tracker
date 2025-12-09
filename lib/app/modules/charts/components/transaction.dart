import 'package:yarima_wallet_pro/app/data/helpers/color_helper.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({
    super.key,
    required this.width,
    required this.transaction,
  });

  final double width;
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .05),
      child: ListTile(
        dense: true,
        leading: Image.asset(
          transaction.categoryPath ?? '',
          width: 24,
        ),
        title: Text(
          transaction.categoryName ?? '',
          style: const TextStyle(fontSize: 15),
        ),
        subtitle: Text(transaction.description),
        trailing: Text(
          transaction.transactionType == TransactionType.payment
              ? '- $currencySymbol ${transaction.amount}'
              : '+ $currencySymbol ${transaction.amount}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: ColorHelper().selectColor(transaction),
          ),
        ),
      ),
    );
  }
}
