import 'package:yarima_wallet_pro/app/modules/account/components/account_helper.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/account/components/monthly_transaction.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.sortedMonths,
    required this.allTransactions,
    required this.fromAccount,
    required this.toAccount,
    required this.color,
    required this.selectedMonth,
    required this.transactionBox,
  });

  final List<String> sortedMonths;
  final Set<TransactionModel> allTransactions;
  final String fromAccount;
  final String toAccount;
  final Color color;
  final DateTime selectedMonth;
  final Box<TransactionModel> transactionBox;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedMonths.map<Widget>(
        (month) {
          final DateTime monthDate = DateFormat('MMMM yyyy').parse(month);
          final transactionsForMonth = allTransactions
              .where((transaction) =>
                  transaction.date.year == monthDate.year &&
                  transaction.date.month == monthDate.month)
              .toList()
            ..sort(
                (a, b) => b.date.compareTo(a.date)); // Sort by date descending

          final double totalPaymentAmount = AccountHelper()
              .calculateTotalPaymentAmountForAccounts(
                  transactionsForMonth, fromAccount, toAccount, monthDate);

          final double totalReceiptAmount = AccountHelper()
              .calculateTotalReceiptAmountForAccounts(
                  transactionsForMonth, fromAccount, toAccount, monthDate);

          final double balance = totalReceiptAmount - totalPaymentAmount;

          return MonthlyTransaction(
            month: month,
            totalPaymentAmount: totalPaymentAmount,
            totalReceiptAmount: totalReceiptAmount,
            balance: balance,
            transactionsForMonth: transactionsForMonth,
            color: color,
            selectedMonth: selectedMonth,
            transactionBox: transactionBox,
          );
        },
      ).toList(),
    );
  }
}
