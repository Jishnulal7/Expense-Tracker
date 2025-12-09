import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class SimpleTransactionListItem extends StatelessWidget {
  final String category;
  final String categoryPath;
  final double amount;
  final Function()? onDelete;
  final Color color;

  const SimpleTransactionListItem({
    super.key,
    required this.category,
    required this.amount,
    this.onDelete,
    required this.color,
    required this.categoryPath,
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
              Row(
                children: [
                  Image.asset(
                    categoryPath,
                    width: 24,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Text(
                '$currencySymbol ${amount.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
