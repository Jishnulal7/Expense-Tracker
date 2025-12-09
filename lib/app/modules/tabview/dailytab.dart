import 'package:yarima_wallet_pro/app/modules/tabview/components/dailytab/balance_card.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/dailytab/date_card.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/dailytab/transaction_section.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/dailytab/transfer_section.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_confirmation.dart';
import 'package:yarima_wallet_pro/app/services/hive.dart';
import 'package:intl/intl.dart';

GlobalKey<_DailyTabState> dailyTabKey = GlobalKey<_DailyTabState>();

class DailyTab extends StatefulWidget {
  List<TransactionModel> transactions;
  DateTime selectDailyDate;
  final Function(DateTime) selectDate;
  final Function(DateTime) calculateBalanceForDay;
  final Function calculateTotalReceiptAmount;
  final Function calculateTotalPaymentAmount;
  double balance;
  double previousDayBalance;
  double totalReceiptAmount;
  double totalPaymentAmount;
  final double openingBalance;
  final VoidCallback addTransactionScreen;
  Map<String, List<TransactionModel>> transactionsByDate;
  List<Receipt> receipts;
  List<Payment> payments;
  final Function(double) updateOpeningBalance;
  final Box<TransactionModel> transactionBox;
  DailyTab({
    super.key,
    required this.transactions,
    required this.selectDailyDate,
    required this.selectDate,
    required this.balance,
    required this.previousDayBalance,
    required this.totalReceiptAmount,
    required this.totalPaymentAmount,
    required this.addTransactionScreen,
    required this.openingBalance,
    required this.transactionsByDate,
    required this.receipts,
    required this.payments,
    required this.calculateTotalReceiptAmount,
    required this.calculateTotalPaymentAmount,
    required this.calculateBalanceForDay,
    required this.updateOpeningBalance,
    required this.transactionBox,
  });

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  CalculationManager calculationManager = CalculationManager();
  late TransactionRepository _repository;
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _repository = TransactionRepository();
    _repository.init().then((_) => loadTransactions());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  Future<void> loadTransactions() async {
    final transactions =
        await _repository.getTransactionsForDay(widget.selectDailyDate);
    setState(() {
      widget.transactions = transactions;
      widget.transactionsByDate =
          _repository.groupTransactionsByDay(transactions);
    });
  }

  Map<String, List<TransactionModel>> groupTransactionsByDate(
      List<TransactionModel> transactions) {
    return transactions.fold({},
        (Map<String, List<TransactionModel>> data, transaction) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      data.putIfAbsent(dateKey, () => []).add(transaction);
      return data;
    });
  }

  void removeTransactionsWithRemovedAccount(String removedAccountName) {
    try {
      setState(() {
        widget.transactions.removeWhere((transaction) =>
            transaction.fromAccount == removedAccountName ||
            transaction.toAccount == removedAccountName);
        widget.transactionsByDate =
            groupTransactionsByDate(widget.transactions);
      });
    } catch (e) {
      debugPrint('Error removing transactions with removed account: $e');
    }
  }

  void updateTransactionsWithUpdatedAccountName(
      String oldName, String newName) {
    try {
      setState(() {
        for (final transaction in widget.transactions) {
          if (transaction.fromAccount == oldName) {
            transaction.fromAccount = newName;
          }
          if (transaction.toAccount == oldName) {
            transaction.toAccount = newName;
          }
        }
        widget.transactionsByDate =
            groupTransactionsByDate(widget.transactions);
      });
    } catch (e) {
      debugPrint('Error updating transactions with updated account name: $e');
    }
  }

  void deleteItemsFromBothTabs(List<String> selectedItems) {
    try {
      setState(() {
        for (final dateKey in selectedItems) {
          final transactions = widget.transactionBox.values.where(
              (transaction) =>
                  DateFormat('yyyy-MM-dd').format(transaction.date) == dateKey);
          for (final transaction in transactions) {
            widget.transactionBox.delete(transaction.key);
          }
        }
        _updateTransactionTotals();
      });
    } catch (e) {
      debugPrint('Error deleting items from both tabs: $e');
    }
  }

  void removeTransactionsWithRemovedCategory(String removedCategoryName) {
    try {
      setState(() {
        widget.transactions.removeWhere(
            (transaction) => transaction.categoryName == removedCategoryName);
        widget.transactionsByDate =
            groupTransactionsByDate(widget.transactions);
      });
    } catch (e) {
      debugPrint('Error removing transactions with removed category: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          // _isBottomNavBarVisible = false;
          _isFabVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          // _isBottomNavBarVisible = true;
          _isFabVisible = true;
        });
      }
    }
  }

  restoreData() async {
    await Hive.openBox<TransactionModel>('transactions');
    setState(() {
      loadTransactions();
      debugPrint(widget.transactionBox.values.toString());
    });
  }

  void rebuildWidgetTree() async {
    try {
      var box = await Hive.openBox<TransactionModel>('transactions');
      await box.clear();
      setState(() {
        loadTransactions();
        widget.balance = 0.0;
        widget.previousDayBalance = 0.0;
        widget.totalPaymentAmount = 0.0;
        widget.totalReceiptAmount = 0.0;
        widget.transactions = [];
        widget.transactionsByDate = {};
        widget.receipts = [];
        widget.payments = [];
      });
    } catch (e) {
      debugPrint('Error clearing transaction box: $e');
    }
  }

  void deleteTransactions(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Delete Transaction',
          content: 'Are you sure you want to delete this transaction?',
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => deleteTransactionsFromHive(transaction),
          confirmButtonText: 'Delete',
          cancelButtonText: 'Cancel',
        );
      },
    );
  }

  void updateTransactionsWithUpdatedCategoryName(
      String oldName, String newName) {
    try {
      setState(() {
        for (final transaction in widget.transactions) {
          if (transaction.categoryName == oldName) {
            transaction.categoryName = newName;
          }
        }
      });
    } catch (e) {
      debugPrint('Error updating transactions with updated category name: $e');
    }
  }

  void deleteTransactionsFromHive(TransactionModel transaction) {
    try {
      _repository.deleteTransaction(transaction);

      if (transaction.transactionType != TransactionType.transfer) {
        widget.selectDate(widget.selectDailyDate);
      }
      setState(() {
        // Remove the transaction from the local lists
        widget.transactions.removeWhere((t) => t.id == transaction.id);
        widget.transactionsByDate.forEach((date, transactions) {
          transactions.removeWhere((t) => t.id == transaction.id);
        });
        // Remove empty dates
        widget.transactionsByDate
            .removeWhere((date, transactions) => transactions.isEmpty);
      });

      // Notify MonthlyTab to update its data
      monthlyTabKey.currentState?.updateTransactions(widget.transactionsByDate);

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  void copyTransaction(
      TransactionModel transaction, DateTime targetMonth) async {
    try {
      final DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: widget.selectDailyDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (newDate != null) {
        final copiedTransaction = TransactionModel(
            amount: transaction.amount,
            description: transaction.description,
            categoryName: transaction.categoryName,
            date: newDate,
            id: transaction.id,
            transactionType: transaction.transactionType,
            categoryPath: transaction.categoryPath,
            fromAccount: transaction.fromAccount,
            toAccount: transaction.toAccount,
            fromAccountImagePath: transaction.fromAccountImagePath,
            toAccountImagePath: transaction.toAccountImagePath,
            fromSubAccount: transaction.fromSubAccount,
            generalCategory: transaction.generalCategory,
            generalSubCategory: transaction.generalSubCategory,
            subCategory: transaction.subCategory,
            toSubAccount: transaction.toSubAccount);

        final dateKey = DateFormat('yyyy-MM-dd').format(newDate);
        widget.transactionsByDate
            .putIfAbsent(dateKey, () => [])
            .add(copiedTransaction);

        await widget.transactionBox.add(copiedTransaction);

        setState(() {
          widget.transactions.add(copiedTransaction);
          widget.transactionsByDate =
              groupTransactionsByDate(widget.transactions);
        });
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error copying transaction: $e');
    }
  }

  void editTransactions(TransactionModel transaction) {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: EditScreen(
            transaction: transaction,
            selectedDailyDate: widget.selectDailyDate,
            transactionBox: widget.transactionBox,
          ),
        ),
      ).then((updatedTransaction) {
        if (updatedTransaction != null) {
          setState(() {
            widget.transactionBox
                .put(updatedTransaction.key, updatedTransaction);
            if (updatedTransaction.transactionType !=
                TransactionType.transfer) {
              // Change this line
              widget.selectDate(widget.selectDailyDate);
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Error editing transaction: $e');
    }
  }

  void _updateTransactionTotals() {
    widget.totalPaymentAmount = widget.calculateTotalPaymentAmount();
    widget.totalReceiptAmount = widget.calculateTotalReceiptAmount();
    widget.balance = widget.calculateBalanceForDay(widget.selectDailyDate);
  }

  Map<DateTime, double> calculateDailyAccountBalance(
      String accountName, DateTime startDate, DateTime endDate) {
    Map<DateTime, double> dailyBalances = {};
    double runningBalance = 0.0;

    // Start from the day before startDate to get the opening balance
    DateTime currentDate = startDate.subtract(const Duration(days: 1));

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      List<TransactionModel> dayTransactions = widget.transactionBox.values
          .where((t) =>
              DateFormat('yyyy-MM-dd').format(t.date) ==
              DateFormat('yyyy-MM-dd').format(currentDate))
          .toList();

      for (var transaction in dayTransactions) {
        if (transaction.fromAccount == accountName) {
          if (transaction.transactionType == TransactionType.payment) {
            runningBalance -= transaction.amount;
          } else if (transaction.transactionType == TransactionType.receipt) {
            runningBalance += transaction.amount;
          } else if (transaction.transactionType == TransactionType.transfer) {
            runningBalance -= transaction.amount;
          }
        }

        if (transaction.toAccount == accountName) {
          if (transaction.transactionType == TransactionType.transfer) {
            runningBalance += transaction.amount;
          }
        }
      }

      dailyBalances[currentDate] = runningBalance;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dailyBalances;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateKey =
        DateFormat('yyyy-MM-dd').format(widget.selectDailyDate);
    final selectedDateTransactions = widget.transactionBox.values
        .where((transaction) =>
            DateFormat('yyyy-MM-dd').format(transaction.date) ==
            selectedDateKey)
        .toList();

    final receipts = widget.calculateTotalReceiptAmount();
    final payments = widget.calculateTotalPaymentAmount();
    final balance = widget.calculateBalanceForDay(widget.selectDailyDate);
    final cashBalances = calculateDailyAccountBalance(
        'Cash', // Replace with the actual account name you want to track
        widget.selectDailyDate.subtract(
            const Duration(days: 30)), // Start date (e.g., 30 days ago)
        widget.selectDailyDate // End date (current selected date)
        );
    final cashBalance = cashBalances[widget.selectDailyDate] ?? 0.0;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          DateNavigationCard(
            selectDailyDate: widget.selectDailyDate,
            balance: balance,
            selectDate: widget.selectDate,
          ),
          const SizedBox(height: 7),
          OpeningBalanceWidget(
            accountBalance: cashBalance,
          ),
          const SizedBox(height: 5),
          TransactionSection(
            title: 'Expense',
            transactions: selectedDateTransactions
                .where((t) => t.transactionType == TransactionType.payment)
                .toList(),
            index: 1,
            totalAmount: payments,
            editTransactions: editTransactions,
            deleteTransactions: deleteTransactions,
            copyTransaction: copyTransaction,
          ),
          const SizedBox(height: 5),
          TransactionSection(
            title: 'Income',
            transactions: selectedDateTransactions
                .where((t) => t.transactionType == TransactionType.receipt)
                .toList(),
            index: 2,
            totalAmount: receipts,
            editTransactions: editTransactions,
            deleteTransactions: deleteTransactions,
            copyTransaction: copyTransaction,
          ),
          const SizedBox(height: 5),
          TransferSection(
            transactions: selectedDateTransactions,
            title: 'Transfers',
            editTransactions: editTransactions,
            deleteTransactions: deleteTransactions,
            copyTransaction: copyTransaction,
          ),
        ],
      ),
    );
  }
}
