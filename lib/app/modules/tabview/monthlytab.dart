import 'package:yarima_wallet_pro/app/modules/tabview/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/custom_appbar.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/date_row.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/monthlytab/transaction_data.dart';
import 'package:intl/intl.dart';

GlobalKey<_MonthlyTabState> monthlyTabKey = GlobalKey<_MonthlyTabState>();

class MonthlyTab extends StatefulWidget {
  DateTime selectMonth;
  DateTime selectedYear;
  final Function(DateTime) calculatePreviousMonthBalance;
  final Map<String, List<TransactionModel>> transactionsByMonth;
  final void Function(DateTime) changeToDailyTab;
  final Function(DateTime) calculateTotalPaymentAmountForMonth;
  final Function(DateTime) calculateTotalReceiptAmountForMonth;
  final Function(DateTime) calculateBalance;
  final Function(DateTime) calculateBalanceForMonth;
  final Function calculateTotalReceiptAmount;
  final Function calculateTotalPaymentAmount;
  final Function(DateTime) getPaymentsForDay;
  final Function(DateTime) getReceiptsForDay;
  final Function(DateTime) getTransfersForDay;
  final Function(DateTime) onMonthSelected;
  final VoidCallback addTransactionScreen;
  final Function(double) updateOpeningBalance;
  final Box<TransactionModel> transactionBox;
  MonthlyTab({
    required this.selectedYear,
    required this.selectMonth,
    required this.transactionsByMonth,
    required this.changeToDailyTab,
    super.key,
    required this.calculateTotalPaymentAmountForMonth,
    required this.calculateTotalReceiptAmountForMonth,
    required this.calculateBalance,
    required this.calculateTotalReceiptAmount,
    required this.calculateTotalPaymentAmount,
    required this.calculatePreviousMonthBalance,
    required this.getPaymentsForDay,
    required this.getReceiptsForDay,
    required this.calculateBalanceForMonth,
    required this.addTransactionScreen,
    required this.getTransfersForDay,
    required this.onMonthSelected,
    required this.updateOpeningBalance,
    required this.transactionBox,
  });

  @override
  State<MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<MonthlyTab> {
  int selectedItemsCount = 0;
  List<String> selectedItems = [];
  bool isSelectionModeActive = false;
  double totalReceipts = 0.0;
  double totalBalance = 0.0;
  double totalPayments = 0.0;
  double closingBalance = 0.0;

  Map<String, double> closingBalances = {};
  late Map<String, List<TransactionModel>> filteredTransactionsByMonth = {};
  Map<String, double> dayBalancesByDay = {};
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    loadTransactionsFromHive();
    filterTransactionsForSelectedMonth(widget.selectMonth);
    closingBalance = widget.calculatePreviousMonthBalance(widget.selectMonth);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
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

  updateSelectedMonth(DateTime newSelectedMonth) {
    setState(() {
      widget.selectMonth = newSelectedMonth;
      filterTransactionsForSelectedMonth(newSelectedMonth);
      closingBalance = widget.calculatePreviousMonthBalance(newSelectedMonth);
      isSelectionModeActive = false;
      selectedItems.clear();
      selectedItemsCount = 0;
    });
  }

  void loadTransactionsFromHive() async {
    try {
      final monthlyTransactionBox =
          await Hive.openBox<TransactionModel>('transactions');
      final selectedMonthKey = DateFormat('yyyy-MM').format(widget.selectMonth);
      final allTransactionsForMonth = monthlyTransactionBox.values.where(
          (transaction) =>
              DateFormat('yyyy-MM').format(transaction.date) ==
              selectedMonthKey);
      final filteredTransactions = allTransactionsForMonth.where(
          (transaction) =>
              transaction.date.month == widget.selectMonth.month &&
              transaction.date.year == widget.selectMonth.year);
      setState(() {
        filteredTransactionsByMonth =
            groupTransactionsByDay(filteredTransactions.toList());
        updateClosingBalance(widget.selectMonth);
      });
      widget.onMonthSelected(widget.selectMonth);
    } catch (e) {
      debugPrint('Error loading transactions from Hive: $e');
    }
  }

  void rebuildWidgetTree() async {
    try {
      var box = await Hive.openBox<TransactionModel>('transactions');
      await box.clear();
      setState(() {
        filteredTransactionsByMonth.clear();
        selectedItems.clear();
        closingBalance = 0.0;
        deleteSelectedItems(selectedItems);
      });
    } catch (e) {
      debugPrint('Error clearing transaction box: $e');
    }
  }

  void updateSelectionAfterRestore() {
    setState(() {
      // Revalidate selected items
      selectedItems = selectedItems
          .where((dayKey) => filteredTransactionsByMonth.containsKey(dayKey))
          .toList();

      // Update selection mode and count
      isSelectionModeActive = selectedItems.isNotEmpty;
      selectedItemsCount = selectedItems.length;
    });
  }

  restoreData() async {
    await Hive.openBox<TransactionModel>('transactions');
    setState(() {
      loadTransactionsFromHive();
      updateSelectionAfterRestore();
      debugPrint(widget.transactionBox.values.toString());
    });
  }

  void updateClosingBalance(DateTime newSelectedDate) {
    try {
      final selectedMonthKey = DateFormat('yyyy-MM').format(newSelectedDate);
      if (closingBalances.containsKey(selectedMonthKey)) {
        closingBalance = closingBalances[selectedMonthKey]!;
      } else {
        closingBalance = widget.calculatePreviousMonthBalance(newSelectedDate);
        closingBalances[selectedMonthKey] = closingBalance;
      }
    } catch (e) {
      debugPrint('Error updating closing balance: $e');
    }
  }

  void updateTransactions(
      Map<String, List<TransactionModel>> newTransactionsByDate) {
    try {
      setState(() {
        filteredTransactionsByMonth = newTransactionsByDate;
      });
    } catch (e) {
      debugPrint('Error updating transactions: $e');
    }
  }

  void filterTransactionsForSelectedMonth(DateTime selectedDate) {
    try {
      final selectedMonthKey = DateFormat('yyyy-MM').format(selectedDate);
      final transactionsForMonth =
          widget.transactionsByMonth[selectedMonthKey] ?? [];
      final filteredTransactions = transactionsForMonth.where((transaction) =>
          transaction.date.month == selectedDate.month &&
          transaction.date.year == selectedDate.year);
      setState(() {
        filteredTransactionsByMonth =
            groupTransactionsByDay(filteredTransactions.toList());
      });
    } catch (e) {
      debugPrint('Error filtering transactions for selected month: $e');
    }
  }

  Map<String, List<TransactionModel>> groupTransactionsByDay(
      List<TransactionModel> transactions) {
    try {
      final Map<String, List<TransactionModel>> transactionsByDay = {};
      for (final transaction in transactions) {
        final dayKey = DateFormat('yyyy-MM-dd').format(transaction.date);
        transactionsByDay.putIfAbsent(dayKey, () => []);
        if (!transactionsByDay[dayKey]!.contains(transaction)) {
          transactionsByDay[dayKey]!.add(transaction);
        }
      }
      return transactionsByDay;
    } catch (e) {
      debugPrint('Error grouping transactions by day: $e');
      return {};
    }
  }

  Future _selectMonthYear(BuildContext context) async {
    try {
      showMonthPicker(
        context: context,
        initialDate: widget.selectMonth,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2101, 12),
      ).then((date) {
        if (date != null) {
          setState(() {
            widget.selectMonth = date;
            filterTransactionsForSelectedMonth(date);
            closingBalance = widget.calculatePreviousMonthBalance(date);
            isSelectionModeActive = false;
            selectedItems.clear();
            selectedItemsCount = 0;
          });
        }
      });
    } catch (e) {
      debugPrint('Error selecting month/year: $e');
    }
  }

  List<TransactionModel> filterTransactionsForMonth(
      List<TransactionModel> allTransactions, DateTime selectedDate) {
    try {
      return allTransactions.where((transaction) {
        return transaction.date.month == selectedDate.month &&
            transaction.date.year == selectedDate.year;
      }).toList();
    } catch (e) {
      debugPrint('Error filtering transactions for month: $e');
      return [];
    }
  }

  double calculateBalanceForDay(DateTime date) {
    try {
      return widget.calculateBalance(date);
    } catch (e) {
      debugPrint('Error calculating balance for day: $e');
      return 0.0;
    }
  }

  double calculateBalanceForMonth(DateTime month) {
    try {
      return widget.calculateBalanceForMonth(month);
    } catch (e) {
      debugPrint('Error calculating balance for month: $e');
      return 0.0;
    }
  }

  void deleteSelectedItems(List<String> selectedItems) {
    try {
      setState(() {
        for (final dayKey in selectedItems) {
          filteredTransactionsByMonth.remove(dayKey);
          final transactions = widget.transactionBox.values.where(
              (transaction) =>
                  DateFormat('yyyy-MM-dd').format(transaction.date) == dayKey);
          for (final transaction in transactions) {
            widget.transactionBox.delete(transaction.key);
          }
        }
        selectedItems.clear();
        isSelectionModeActive = false;
        selectedItemsCount = 0;
        loadTransactionsFromHive();
      });
    } catch (e) {
      debugPrint('Error deleting selected items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = filteredTransactionsByMonth.keys
        .where((dayKey) =>
            DateTime.parse(dayKey).month == widget.selectMonth.month &&
            DateTime.parse(dayKey).year == widget.selectMonth.year)
        .toList()
      ..sort((a, b) => DateTime.parse(b).day.compareTo(DateTime.parse(a).day));

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          if (isSelectionModeActive)
            CustomAppBar(
              sortedDates: sortedDates,
              onBackPressed: () {
                setState(() {
                  isSelectionModeActive = false;
                  selectedItems.clear();
                  selectedItemsCount = 0;
                });
              },
              onSelectAll: () {
                setState(() {
                  selectedItems = sortedDates.map((dayKey) => dayKey).toList();
                  selectedItemsCount = selectedItems.length;
                });
              },
              onDelete: () {
                deleteSelectedItems(selectedItems);
                setState(() {});
              },
              selectedItemsCount: selectedItemsCount,
            ),
          DateSelectionRow(
            selectMonth: widget.selectMonth,
            onPreviousMonth: _navigateToPreviousMonth,
            onNextMonth: _navigateToNextMonth,
            onSelectMonthYear: () => _selectMonthYear(context),
          ),
          FinancialSummaryWidget(
            data: FinancialData(
              totalReceipts: widget
                  .calculateTotalReceiptAmountForMonth(widget.selectMonth)
                  .toStringAsFixed(1),
              totalPayments: widget
                  .calculateTotalPaymentAmountForMonth(widget.selectMonth)
                  .toStringAsFixed(1),
              carryForward: widget
                  .calculatePreviousMonthBalance(widget.selectMonth)
                  .toStringAsFixed(1),
              balance: calculateBalanceForMonth(widget.selectMonth)
                  .toStringAsFixed(1),
            ),
          ),
          TransactionData(
            sortedDates: sortedDates,
            filteredTransactionsByMonth: filteredTransactionsByMonth,
            getReceiptsForDay: widget.getReceiptsForDay,
            getPaymentsForDay: widget.getPaymentsForDay,
            getTransfersForDay: widget.getTransfersForDay,
            calculateBalanceForDay: calculateBalanceForDay,
            changeToDailyTab: widget.changeToDailyTab,
            isSelectionModeActive: isSelectionModeActive,
            onSelectItem: (dayKey) {
              setState(() {
                if (selectedItems.contains(dayKey)) {
                  selectedItems.remove(dayKey);
                  if (selectedItems.isEmpty) {
                    isSelectionModeActive = false;
                    selectedItemsCount = 0;
                  } else {
                    selectedItemsCount = selectedItems.length;
                  }
                } else {
                  selectedItems.add(dayKey);
                  selectedItemsCount = selectedItems.length;
                }
              });
            },
            onLongPressItem: (dayKey) {
              if (!selectedItems.contains(dayKey)) {
                setState(() {
                  selectedItems.add(dayKey);
                  isSelectionModeActive = true;
                  selectedItemsCount = selectedItems.length;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToPreviousMonth() {
    final newDate = widget.selectMonth.subtract(
      Duration(
        days: ColorHelper().getDaysInMonth(
          widget.selectMonth.month,
        ),
      ),
    );
    filterTransactionsForSelectedMonth(newDate);
    updateClosingBalance(newDate);

    setState(() {
      widget.selectMonth = newDate;
      isSelectionModeActive = false;
      selectedItems.clear();
      selectedItemsCount = 0;
    });
  }

  void _navigateToNextMonth() {
    final newDate = widget.selectMonth.add(
      Duration(
        days: ColorHelper().getDaysInMonth(
          widget.selectMonth.month,
        ),
      ),
    );
    filterTransactionsForSelectedMonth(newDate);
    updateClosingBalance(newDate);

    setState(() {
      widget.selectMonth = newDate;
      isSelectionModeActive = false;
      selectedItems.clear();
      selectedItemsCount = 0;
    });
  }
}
