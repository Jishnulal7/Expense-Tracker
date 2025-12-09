import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';

class AccountHelper {
  final allTransactionTypes = [
    TransactionType.payment,
    TransactionType.receipt,
    TransactionType.transfer,
  ];

  getIcon(TransactionModel transactions) {
    try {
      if (transactions.transactionType == TransactionType.transfer) {
        return 'assets/categories/swap-hori.png';
      } else {
        return CustomIcons()
            .getImagePathForCategory(transactions.categoryName!);
      }
    } catch (e) {
      debugPrint('Error while getting icon: $e');
      return Icons.error;
    }
  }

  Widget transactionType(TransactionModel transactions) {
    try {
      if (transactions.transactionType == TransactionType.transfer) {
        return Expanded(
          child: Row(
            children: [
              Flexible(child: Text(transactions.fromAccount)),
              const Icon(Icons.arrow_right_alt),
              Flexible(child: Text(transactions.toAccount)),
            ],
          ),
        );
      } else {
        return Flexible(child: Text(transactions.categoryName!));
      }
    } catch (e) {
      debugPrint('Error while getting transaction type: $e');
      return const Text('Unknown');
    }
  }

  double calculateAccountBalance(
    Set<TransactionModel> transactions,
    String fromAccount,
    String toAccount,
    Map<String, dynamic>? categoryData,
  ) {
    try {
      double balance =
          categoryData != null ? categoryData['initialAmount'] ?? 0 : 0;

      for (final transaction in transactions) {
        if (transaction.transactionType == TransactionType.payment) {
          balance -= transaction.amount;
        } else if (transaction.transactionType == TransactionType.receipt) {
          balance += transaction.amount;
        } else if (transaction.transactionType == TransactionType.transfer) {
          if (transaction.fromAccount == fromAccount) {
            balance -= transaction.amount;
          } else if (transaction.toAccount == toAccount) {
            balance += transaction.amount;
          }
        }
      }

      return balance;
    } catch (e) {
      debugPrint('Error while calculating account balance: $e');
      return 0;
    }
  }

  double calculateTotalPaymentAmountForAccounts(
    List<TransactionModel> transactions,
    String fromAccount,
    String toAccount,
    DateTime month,
  ) {
    double totalPayment = 0.0;
    for (var transaction in transactions) {
      if (transaction.date.year == month.year &&
          transaction.date.month == month.month) {
        if (transaction.transactionType == TransactionType.payment) {
          if (transaction.fromAccount == fromAccount ||
              transaction.toAccount == toAccount) {
            totalPayment += transaction.amount;
          }
        } else if (transaction.transactionType == TransactionType.transfer) {
          if (transaction.fromAccount == fromAccount) {
            totalPayment += transaction.amount;
          }
        }
      }
    }
    return totalPayment;
  }

  double calculateTotalReceiptAmountForAccounts(
    List<TransactionModel> transactions,
    String fromAccount,
    String toAccount,
    DateTime month,
  ) {
    double totalReceipt = 0.0;
    for (var transaction in transactions) {
      if (transaction.date.year == month.year &&
          transaction.date.month == month.month) {
        if (transaction.transactionType == TransactionType.receipt) {
          if (transaction.fromAccount == fromAccount ||
              transaction.toAccount == toAccount) {
            totalReceipt += transaction.amount;
          }
        } else if (transaction.transactionType == TransactionType.transfer) {
          if (transaction.toAccount == toAccount) {
            totalReceipt += transaction.amount;
          }
        }
      }
    }
    return totalReceipt;
  }

  List<TransactionModel> getTransactionsOfAccounts(
    DateTime selectedMonth,
    Box<TransactionModel> transactionBox,
    List<TransactionType> types,
    String fromAccount,
    String toAccount,
  ) {
    try {
      final transactions = <TransactionModel>[];

      for (final transaction in transactionBox.values) {
        if (types.contains(transaction.transactionType) &&
            ((transaction.fromAccount == fromAccount) ||
                (transaction.toAccount == toAccount))) {
          // Check if the transaction's date falls within the selected month
          if ((transaction.date.year == selectedMonth.year &&
                  transaction.date.month == selectedMonth.month) ||
              // Also include transactions from previous and next years
              (transaction.date.year < selectedMonth.year ||
                  transaction.date.month < selectedMonth.month) ||
              (transaction.date.year > selectedMonth.year ||
                  transaction.date.month > selectedMonth.month)) {
            transactions.add(transaction);
          }
        }
      }
      return transactions;
    } catch (e) {
      debugPrint('Error while getting transactions of accounts: $e');
      return [];
    }
  }

  final List<Map<String, dynamic>> accountCategories = [
    {
      'name': 'Cash',
      'imagePath': 'assets/categories/cash-bill-dollar.png',
      'initialAmount': 0.0,
      'subAccount': [],
    },
    {
      'name': 'Card',
      'imagePath': 'assets/categories/credit-card.png',
      'initialAmount': 0.0,
      'subAccount': [],
    },
    {
      'name': 'Bank',
      'imagePath': 'assets/categories/bank.png',
      'initialAmount': 0.0,
      'subAccount': [],
    },
    {
      'name': 'Savings',
      'imagePath': 'assets/categories/piggy-bank.png',
      'initialAmount': 0.0,
      'subAccount': [],
    },
  ];
  void addAccount(String name, String icon, {List<dynamic>? subAccounts}) {
    accountCategories.add({
      'name': name,
      'imagePath': icon,
      'initialAmount': 0.0,
    });
  }

  void initializeDefaultAccounts() {
    final accountsBox = GetStorage('accounts');
    for (var account in accountCategories) {
      if (!accountsBox.hasData(account['name'])) {
        accountsBox.write(account['name'], {
          'imagePath': account['imagePath'],
          'initialAmount': account['initialAmount'],
        });
      } else {
        final existingData = accountsBox.read(account['name']);
        if (existingData != null && !existingData.containsKey('subAccount')) {
          accountsBox.write(account['name'], existingData);
        }
      }
    }
  }
}
