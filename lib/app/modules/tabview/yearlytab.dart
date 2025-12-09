import 'package:yarima_wallet_pro/app/modules/account/components/exports.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class YearlyTab extends StatefulWidget {
  final Map<String, Map<String, dynamic>> yearlyData;
  final Function(DateTime) getPaymentsForMonth;
  final Function(DateTime) getReceiptsForMonth;
  final Function(DateTime) getTransfersForMonth;
  final VoidCallback addTransactionScreen;
  DateTime selectedMonth;
  DateTime selectedYear;
  final Function(DateTime) changeToMonthlyTab;
  final Function(double) updateOpeningBalance;
  final Function(DateTime) calculatePreviousMonthBalance;
  Box<TransactionModel> transactionBox;
  YearlyTab({
    super.key,
    required this.yearlyData,
    required this.getPaymentsForMonth,
    required this.getReceiptsForMonth,
    required this.addTransactionScreen,
    required this.selectedMonth,
    required this.changeToMonthlyTab,
    required this.selectedYear,
    required this.getTransfersForMonth,
    required this.updateOpeningBalance,
    required this.transactionBox,
    required this.calculatePreviousMonthBalance,
  });

  static const Map<String, int> monthIndexMapping = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  static List<String> orderedMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  State<YearlyTab> createState() => _YearlyTabState();
}

class _YearlyTabState extends State<YearlyTab> {
  List<int> availableYears = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getDataFromHive();
    _populateAvailableYears();
  }

  Future<void> _getDataFromHive() async {
    try {
      widget.transactionBox =
          await Hive.openBox<TransactionModel>('transactions');
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching yearly data from Hive: $e');
    }
  }

  void _populateAvailableYears() {
    availableYears = widget.yearlyData.keys
        .map((monthYear) => DateFormat('MMMM yyyy').parse(monthYear).year)
        .toSet()
        .toList()
      ..sort();
  }

  void _changeSelectedYear(int offset) {
    setState(() {
      widget.selectedMonth = DateTime(widget.selectedMonth.year + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentYear = widget.selectedMonth.year == DateTime.now().year;
    final sortedEntries = _getSortedEntries();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildYearNavigation(isCurrentYear),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMonthlyDataCard(sortedEntries[index]),
              childCount: sortedEntries.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearNavigation(bool isCurrentYear) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeSelectedYear(-1),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          GestureDetector(
            onTap: _showYearPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentYear
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.selectedMonth.year.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isCurrentYear ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeSelectedYear(1),
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyDataCard(MapEntry<String, Map<String, dynamic>> entry) {
    final month = entry.key;
    final data = entry.value;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final parsedDate = DateFormat('MMMM yyyy').parse(entry.key);
          widget.selectedMonth = parsedDate; // Update the selectedMonth
          widget.changeToMonthlyTab(parsedDate);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _buildDataRow("Receipts", data['totalReceipts'], AppColor.kGreen),
              _buildDataRow("Payments", data['totalPayments'], AppColor.kRed),
              _buildDataRow("Balance", data['balance'], AppColor.kPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value, Color color) {
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "$currencySymbol $value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(availableYears.first),
              lastDate: DateTime(availableYears.last),
              selectedDate: widget.selectedMonth,
              onChanged: (DateTime dateTime) {
                setState(() {
                  widget.selectedMonth =
                      DateTime(dateTime.year, widget.selectedMonth.month);
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  List<MapEntry<String, Map<String, dynamic>>> _getSortedEntries() {
    return widget.yearlyData.entries.where((entry) {
      final parsedDate = DateFormat('MMMM yyyy').parse(entry.key);
      return parsedDate.year == widget.selectedMonth.year;
    }).toList()
      ..sort((a, b) => YearlyTab.orderedMonths
          .indexOf(a.key.split(' ')[0])
          .compareTo(YearlyTab.orderedMonths.indexOf(b.key.split(' ')[0])));
  }
}
