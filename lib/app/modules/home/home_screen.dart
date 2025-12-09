import 'package:yarima_wallet_pro/app/modules/charts/charts.dart';
import 'package:yarima_wallet_pro/app/modules/home/components/search_screen.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/monthly_pdf.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/yearly_pdf.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/exports.dart';
import 'package:yarima_wallet_pro/app/services/hive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionRepository _transactionRepository;
  final Box<TransactionModel> _transactionBox =
      Hive.box<TransactionModel>('transactions');
  late DateTime selectedMonth = DateTime.now();
  late DateTime selectedYear = DateTime.now();
  DateTime selectDailyDate = DateTime.now();
  double monthlyTotalPayments = 0.0;
  double monthlyTotalReceipts = 0.0;
  double totalReceiptAmount = 0.0;
  double totalPaymentAmount = 0.0;
  double balance = 0;
  double previousDayBalance = 0;
  double totalBalance = 0.0;
  double openingBalance = 0.0;
  List<TransactionModel> transactions = [];
  List<Receipt> receipts = [];
  List<Payment> payments = [];
  Map<String, List<TransactionModel>> transactionsByDate = {};
  Map<String, List<TransactionModel>> transactionsByMonth = {};

  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 1;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _transactionRepository = TransactionRepository();
    _transactionRepository.init().then((_) {
      loadTransactionsFromHive();
    });
    transactionsByDate[DateFormat('yyyy-MM-dd').format(selectDailyDate)] = [];
    previousDayBalance = openingBalance;
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    selectedMonth = DateTime.now();
    _selectDate(selectDailyDate);
  }

  void notifyTabUpdate() {
    totalReceiptAmount = calculateTotalReceiptAmount();
    totalPaymentAmount = calculateTotalPaymentAmount();
    balance = calculateBalanceForDay(selectDailyDate);
    monthlyTabKey.currentState?.updateTransactions(transactionsByDate);
    monthlyTotalPayments = calculateTotalPaymentAmountForMonth(selectDailyDate);
    monthlyTotalReceipts = calculateTotalReceiptAmountForMonth(selectDailyDate);
    transactionsByMonth =
        CalculationManager().groupTransactionsByMonth(transactionsByDate);
    setState(() {});
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _refreshCurrentDate();
    }
  }

  void _changeToDailyTab(DateTime selectedDate) {
    _tabController.animateTo(0);
    _selectDate(selectedDate);
  }

  void _updateSelectedMonth(DateTime newMonth) {
    _tabController.animateTo(1);
    setState(() {
      selectedMonth = newMonth;
    });
  }

  void updateOpeningBalance(double newOpeningBalance) {
    setState(() {
      openingBalance = newOpeningBalance;
      previousDayBalance = newOpeningBalance;
    });
  }

  Future<void> _refreshCurrentDate() async {
    setState(() {
      selectDailyDate = DateTime.now();
      selectedMonth = DateTime.now();
      selectedYear = DateTime.now();
    });
  }

  Future<void> loadTransactionsFromHive() async {
    try {
      transactions = await _transactionRepository.getAllTransactions();
      transactionsByDate =
          _transactionRepository.groupTransactionsByDay(transactions);
      notifyTabUpdate();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading transactions from Hive: $e');
    }
  }

  Future addUpdatedTransaction(TransactionModel updatedTransaction) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(updatedTransaction.date);
      await _transactionRepository.updateTransaction(updatedTransaction);

      transactionsByDate[dateKey] ??= [];
      transactionsByDate[dateKey]!.add(updatedTransaction);

      if (updatedTransaction is Receipt) {
        receipts.add(updatedTransaction);
      } else if (updatedTransaction is Payment) {
        payments.add(updatedTransaction);
      }

      notifyTabUpdate();
      setState(() {});
    } catch (e) {
      debugPrint('Error adding transaction to Hive: $e');
    }
  }

  void updateTransaction(TransactionModel updatedTransaction, int index) {
    if (updatedTransaction is Receipt) {
      receipts[index] = updatedTransaction;
    } else if (updatedTransaction is Payment) {
      payments[index] = updatedTransaction;
    }

    double totalReceiptAmount = calculateTotalReceiptAmount();
    double totalPaymentAmount = calculateTotalPaymentAmount();
    double balance = calculateBalanceForDay(selectDailyDate);

    setState(() {
      totalReceiptAmount = totalReceiptAmount;
      totalPaymentAmount = totalPaymentAmount;
      balance = balance;
    });
  }

  double calculateTotalPaymentAmount() {
    return CalculationManager()
        .calculateTotalPaymentAmount(selectDailyDate, _transactionBox);
  }

  double calculateTotalReceiptAmount() {
    return CalculationManager()
        .calculateTotalReceiptAmount(selectDailyDate, _transactionBox);
  }

  double calculateTotalPaymentAmountForMonth(DateTime selectedMonth) {
    return CalculationManager()
        .calculateTotalPaymentAmountForMonth(selectedMonth, _transactionBox);
  }

  double calculateTotalReceiptAmountForMonth(DateTime selectedMonth) {
    return CalculationManager()
        .calculateTotalReceiptAmountForMonth(selectedMonth, _transactionBox);
  }

  double calculateBalanceForDay(DateTime selectedDate) {
    return CalculationManager()
        .calculateBalanceForDay(selectedDate, openingBalance, _transactionBox);
  }

  double calculateBalanceForMonth(DateTime month) {
    return CalculationManager()
        .calculateBalanceForMonth(month, openingBalance, _transactionBox);
  }

  double calculatePreviousMonthBalance(DateTime month) {
    return CalculationManager()
        .calculatePreviousMonthBalance(month, openingBalance, _transactionBox);
  }

  Map<String, Map<String, double>> calculateYearlyData(
    Map<String, List<TransactionModel>> transactionsByMonth,
    double openingBalance,
  ) {
    return CalculationManager().calculateYearlyData(
      transactionsByMonth,
      openingBalance,
      _transactionBox,
    );
  }

  List<Payment> getPaymentsForMonth(DateTime selectedMonth) {
    return CalculationManager().getPaymentsForMonth(
      selectedMonth,
      _transactionBox,
    );
  }

  List<Payment> getPaymentsForDay(DateTime selectedMonth) {
    return CalculationManager().getPaymentsFromHive(
      _transactionBox,
      selectedMonth,
    );
  }

  List<Transfer> getTransfersForDay(DateTime selectedMonth) {
    return CalculationManager().getTransfersFromHive(
      _transactionBox,
      selectedMonth,
    );
  }

  List<Receipt> getReceiptsForDay(DateTime selectedMonth) {
    return CalculationManager().getReceiptsFromHive(
      _transactionBox,
      selectedMonth,
    );
  }

  List<Payment> getPaymentsForYear(DateTime selectedMonth) {
    return CalculationManager().getPaymentsForYear(
      selectedMonth,
      _transactionBox,
    );
  }

  List<Receipt> getReceiptsForMonth(DateTime selectedMonth) {
    return CalculationManager().getReceiptsForMonth(
      selectedMonth,
      _transactionBox,
    );
  }

  List<Receipt> getReceiptsForYear(DateTime selectedMonth) {
    return CalculationManager().getReceiptsForYear(
      selectedMonth,
      _transactionBox,
    );
  }

  List<Transfer> getTransfersForMonth(DateTime selectedMonth) {
    return CalculationManager().getTransfersForYear(
      _transactionBox,
      selectedMonth,
    );
  }

  void _selectDate(DateTime newDate) {
    setState(() {
      selectDailyDate = newDate;
      totalReceiptAmount = calculateTotalReceiptAmount();
      totalPaymentAmount = calculateTotalPaymentAmount();
      balance = calculateBalanceForDay(selectDailyDate);
      previousDayBalance =
          calculateBalanceForDay(newDate.subtract(const Duration(days: 1)));
      monthlyTotalPayments = calculateTotalPaymentAmountForMonth(selectedMonth);
      monthlyTotalReceipts = calculateTotalReceiptAmountForMonth(selectedMonth);
      transactionsByMonth =
          CalculationManager().groupTransactionsByMonth(transactionsByDate);
    });
  }

  void _addTransaction() async {
    try {
      final newTransaction = await showModalBottomSheet<TransactionModel>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AddTransactionScreen(
                  selectedDate: selectDailyDate,
                  onAddTransaction: addUpdatedTransaction,
                  transactionBox: _transactionBox,
                ),
              ),
            ),
          );
        },
      );

      if (newTransaction != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(newTransaction.date);

        notifyTabUpdate();

        _selectDate(newTransaction.date);

        debugPrint('Date key: $dateKey');
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onMonthSelected(DateTime newDate) {
    setState(() {
      selectDailyDate = newDate;
      notifyTabUpdate();
    });
  }

  void onPopInvoked(bool didPop, dynamic result) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) >
            Duration(seconds: requiredSeconds)) {
      currentBackPressTime = now;
      const CustomToast(
        message: 'Press again to exit',
      ).showToast(context);
      Future.delayed(
        Duration(seconds: requiredSeconds),
        () {
          setState(() {
            canPopNow = false;
          });
          Fluttertoast.cancel();
        },
      );
      setState(() {
        canPopNow = true;
      });
    }
  }

  Future<void> searchAndNavigate(String query) async {
    List<dynamic> searchedItems = [];
    if (query.trim().isEmpty) {
      // For an empty query, we'll show all transactions and attendance records
      searchedItems = [
        ..._transactionBox.values,
      ];
    } else {
      searchedItems = await searchItems(query);
    }
    // Navigate to the search results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          initialItems: searchedItems,
          initialQuery: query,
        ),
      ),
    );
  }

  Future<List<dynamic>> searchItems(String query) async {
    final List<TransactionModel> allTransactions =
        _transactionBox.values.toList();

    // If the query is empty, return all items
    if (query.isEmpty) {
      return [...allTransactions];
    }

    final lowercaseQuery = query.toLowerCase().trim();

    List<dynamic> searchResults = [];

    // Search transactions
    searchResults.addAll(allTransactions.where((transaction) {
      return _matchTransaction(transaction, lowercaseQuery);
    }));

    return searchResults;
  }

  bool _matchTransaction(TransactionModel transaction, String lowercaseQuery) {
    final transactionDate = DateFormat('yyyy-MM-dd').format(transaction.date);
    final transactionAmount = transaction.amount.toString();
    final transactionDescription = transaction.description.toLowerCase();
    final transactionAccount = transaction.fromAccount.toLowerCase();
    final transactionCategory = transaction.categoryName?.toLowerCase() ?? '';

    return transactionDate.contains(lowercaseQuery) ||
        transactionAmount.contains(lowercaseQuery) ||
        transactionDescription.contains(lowercaseQuery) ||
        transactionAccount.contains(lowercaseQuery) ||
        transactionCategory.contains(lowercaseQuery);
  }

  BottomNavBar _buildBottomNavBar() {
    return BottomNavBar(
      items: [
        BottomNavItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Accounts',
          screen: AccountScreen(selectedDailyDate: selectDailyDate),
        ),
        BottomNavItem(
          icon: Icons.category_outlined,
          label: 'Category',
          screen: CategoryScreen(selectDate: selectDailyDate),
        ),
        BottomNavItem(
          icon: Icons.category_outlined,
          label: '',
          screen: const SizedBox(),
        ),
        BottomNavItem(
          icon: Icons.currency_exchange,
          label: 'Budget',
          screen: BudgetDashboardScreen(),
        ),
        BottomNavItem(
          icon: Icons.incomplete_circle_outlined,
          label: 'Analysis',
          screen: ChartsScreen(selectedMonth: selectDailyDate),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      onPress: _addTransaction,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildMonthlyFloatingActionButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          onTap: _addTransaction,
        ),
        SpeedDialChild(
          child: const Icon(Icons.picture_as_pdf),
          onTap: () {
            createMonthlyPdf();
          },
        ),
      ],
    );
  }

  Widget _buildYearlyFloatingActionButton(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          onTap: _addTransaction,
        ),
        SpeedDialChild(
          child: const Icon(Icons.picture_as_pdf),
          onTap: () {
            createYearlyPdf();
          },
        ),
      ],
    );
  }

  Widget _getFloatingActionButton() {
    // Use _tabController.animation!.value instead of _tabController.index
    double animationValue = _tabController.animation!.value;
    if (animationValue < 0.5) {
      return _buildFloatingActionButton();
    } else if (animationValue < 1.5) {
      return _buildMonthlyFloatingActionButton();
    } else {
      return _buildYearlyFloatingActionButton(context);
    }
  }

  createYearlyPdf() async {
    var yearlyData = calculateYearlyData(
      transactionsByMonth,
      openingBalance,
    );
    String pdfPath = await YearlyPDFGenerator(
      yearlyTransactionBox: _transactionBox,
      selectedYear: selectedYear,
      yearlyData: yearlyData,
      closingBalance: previousDayBalance,
    ).generateYearlyPDF();
    YearlyPDFGenerator(
      yearlyTransactionBox: _transactionBox,
      selectedYear: selectedYear,
      yearlyData: yearlyData,
      closingBalance: previousDayBalance,
    ).viewPdf(context, pdfPath, 1, 1);
  }

  createMonthlyPdf() async {
    String pdfPath = await PdfGenerator().generateMonthlyPdfReport(
      selectedMonth,
      previousDayBalance,
      transactionsByMonth,
      context,
    );
    PdfGenerator().viewPdf(
      context,
      pdfPath,
      selectedMonth,
      transactionsByMonth,
      previousDayBalance,
      1,
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvokedWithResult: onPopInvoked,
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              return _getFloatingActionButton();
            },
          ),
          bottomNavigationBar: _buildBottomNavBar(),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => searchAndNavigate(searchQuery),
                icon: const Icon(Icons.search_outlined),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.account_circle_outlined,
                    size: 30,
                  ),
                ),
              ),
            ],
            automaticallyImplyLeading: false,
            title: const Text('Yarima Wallet'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
          ),
          body: buildTabBarView(),
        ),
      ),
    );
  }

  Widget buildTabBarView() {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DailyTab(
                key: dailyTabKey,
                transactions: transactions,
                selectDailyDate: selectDailyDate,
                selectDate: _selectDate,
                balance: balance,
                previousDayBalance: previousDayBalance,
                totalReceiptAmount: totalReceiptAmount,
                totalPaymentAmount: totalPaymentAmount,
                addTransactionScreen: _addTransaction,
                openingBalance: openingBalance,
                transactionsByDate: transactionsByDate,
                payments: payments,
                receipts: receipts,
                calculateTotalReceiptAmount: calculateTotalReceiptAmount,
                calculateTotalPaymentAmount: calculateTotalPaymentAmount,
                calculateBalanceForDay: calculateBalanceForDay,
                updateOpeningBalance: updateOpeningBalance,
                transactionBox: _transactionBox,
              ),
              MonthlyTab(
                selectMonth: selectedMonth,
                changeToDailyTab: _changeToDailyTab,
                key: monthlyTabKey,
                transactionsByMonth: transactionsByMonth,
                calculateTotalPaymentAmountForMonth:
                    calculateTotalPaymentAmountForMonth,
                calculateTotalReceiptAmountForMonth:
                    calculateTotalReceiptAmountForMonth,
                calculateBalance: calculateBalanceForDay,
                calculateTotalReceiptAmount: calculateTotalReceiptAmount,
                calculateTotalPaymentAmount: calculateTotalPaymentAmount,
                calculatePreviousMonthBalance: calculatePreviousMonthBalance,
                getReceiptsForDay: getReceiptsForDay,
                getPaymentsForDay: getPaymentsForDay,
                calculateBalanceForMonth: calculateBalanceForMonth,
                addTransactionScreen: _addTransaction,
                getTransfersForDay: getTransfersForDay,
                selectedYear: selectedYear,
                onMonthSelected: onMonthSelected,
                updateOpeningBalance: updateOpeningBalance,
                transactionBox: _transactionBox,
              ),
              YearlyTab(
                yearlyData: calculateYearlyData(
                  transactionsByMonth,
                  openingBalance,
                ),
                getPaymentsForMonth: getPaymentsForYear,
                getReceiptsForMonth: getReceiptsForYear,
                addTransactionScreen: _addTransaction,
                selectedMonth: selectedMonth,
                changeToMonthlyTab: _updateSelectedMonth,
                selectedYear: selectedYear,
                getTransfersForMonth: getTransfersForMonth,
                updateOpeningBalance: updateOpeningBalance,
                transactionBox: _transactionBox,
                calculatePreviousMonthBalance: calculatePreviousMonthBalance,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
