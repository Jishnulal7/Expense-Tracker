import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/account_pdf.dart';
import 'package:provider/provider.dart';

class AccountInfo extends StatelessWidget {
  const AccountInfo({
    super.key,
    required this.context,
    required this.account,
    required this.color,
    required this.balance,
    required this.transactionBox,
    required this.selectedMonth,
  });

  final BuildContext context;
  final Map<String, dynamic> account;
  final Color color;
  final double balance;
  final Box<TransactionModel> transactionBox;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.asset(account['imagePath']),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    account['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PdfViewScreen(
                            accountName: account['name'],
                            transactions: _filterTransactionsByDateRange(
                              picked.start,
                              picked.end,
                              transactionBox.values.toList(),
                            ),
                            startDate: picked.start,
                            endDate: picked.end,
                          );
                        },
                      ),
                    );
                  }
                },
                label: const Text('View PDF'),
                icon: const Icon(Icons.picture_as_pdf),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Balance: ',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '$currencySymbol ${balance.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _filterTransactionsByDateRange(DateTime startDate,
      DateTime endDate, List<TransactionModel> transactions) {
    // Adjust the end date to include the entire last day
    final adjustedEndDate = endDate.add(const Duration(days: 1));

    return transactions
        .where((transaction) =>
            transaction.date.isAtSameMomentAs(startDate) ||
            transaction.date.isAtSameMomentAs(endDate) ||
            (transaction.date.isAfter(startDate) &&
                transaction.date.isBefore(adjustedEndDate)))
        .toList();
  }
}
