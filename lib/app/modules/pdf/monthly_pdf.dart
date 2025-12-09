import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/monthly_pdf.dart';
import 'package:intl/intl.dart';

class MonthlyPdf extends StatefulWidget {
  MonthlyPdf({
    super.key,
    required this.pdfPath,
    required this.selectMonth,
    required this.subIndex,
    required this.tabIndex,
    required this.transactionsByMonth,
    required this.closingBalance,
  });

  final String pdfPath;
  DateTime selectMonth;
  final int subIndex;
  final int tabIndex;
  final Map<String, List<TransactionModel>> transactionsByMonth;
  final double closingBalance;

  @override
  State<MonthlyPdf> createState() => _MonthlyPdfState();
}

class _MonthlyPdfState extends State<MonthlyPdf> {
  PdfGenerator pdfGenerator = PdfGenerator();
  TextEditingController filterController = TextEditingController();

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180.0),
        child: AppBar(
          title: const Text('Monthly Pdf'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
            child: _buildMonthlyButtons(context),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(context),
      body: SfPdfViewer.file(
        File(widget.pdfPath),
      ),
    );
  }

  Row _buildFloatingActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            try {
              await PdfHelper().savePdf(
                context,
                widget.pdfPath,
                widget.selectMonth,
                widget.tabIndex,
                widget.subIndex,
              );
            } catch (e) {
              debugPrint("Error saving PDF: $e");
            }
          },
          child: const Icon(Icons.download),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            try {
              await PdfHelper().sharePdf(widget.pdfPath);
            } catch (e) {
              debugPrint("Error sharing PDF: $e");
            }
          },
          child: const Icon(Icons.share),
        ),
      ],
    );
  }

  Widget _buildMonthlyButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              _buildBottons(
                'All',
                () async {
                  try {
                    await _createMonthlyPdf(
                      context,
                      widget.selectMonth,
                      pdfGenerator,
                      widget.transactionsByMonth,
                      widget.closingBalance,
                      widget.pdfPath,
                    );
                  } catch (e) {
                    debugPrint("Error creating monthly PDF: $e");
                  }
                },
              ),
              _buildBottons(
                'Expense',
                () async {
                  try {
                    await _createMonthlyPaymentPdf(
                      context,
                      widget.selectMonth,
                      pdfGenerator,
                      widget.transactionsByMonth,
                      widget.pdfPath,
                      widget.closingBalance,
                    );
                  } catch (e) {
                    debugPrint("Error creating monthly payments PDF: $e");
                  }
                },
              ),
              _buildBottons(
                'Income',
                () async {
                  try {
                    await _createMonthlyReceiptPdf(
                      context,
                      widget.selectMonth,
                      pdfGenerator,
                      widget.transactionsByMonth,
                      widget.pdfPath,
                      widget.closingBalance,
                    );
                  } catch (e) {
                    debugPrint("Error creating monthly receipts PDF: $e");
                  }
                },
              ),
              _buildBottons(
                'Transfers',
                () async {
                  try {
                    await _createMonthlyTransfersPdf(
                      context,
                      widget.selectMonth,
                      pdfGenerator,
                      widget.transactionsByMonth,
                      widget.closingBalance,
                      widget.pdfPath,
                    );
                  } catch (e) {
                    debugPrint("Error creating monthly transfers PDF: $e");
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildBottons('Notes', () {
                _showTextfield(context);
              }),
              _buildMonthSelector(context),
            ],
          ),
        ],
      ),
    );
  }

  _showTextfield(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: TextField(
          controller: filterController,
          decoration: const InputDecoration(
            hintText: 'Enter description to filter',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createFilteredPdf(context, filterController.text);
            },
            child: const Text('Filter'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _createFilteredPdf(BuildContext context, String filter) async {
    try {
      final filePath = await pdfGenerator.generateFilteredPdfReport(
        widget.selectMonth,
        widget.transactionsByMonth,
        filter,
        context,
      );
      pdfGenerator.viewPdf(
        context,
        filePath,
        widget.selectMonth,
        widget.transactionsByMonth,
        widget.closingBalance,
        4,
        4,
      );
    } catch (e) {
      debugPrint("Error creating filtered PDF: $e");
    }
  }

  Future<void> _createMonthlyPaymentPdf(
    BuildContext context,
    DateTime selectedDate,
    PdfGenerator pdfGenerator,
    Map<String, List<TransactionModel>> transactionsByMonth,
    String pdfPath,
    double closingBalance,
  ) async {
    try {
      final filePath = await pdfGenerator.generateMonthlyPaymentsPdfReport(
        selectedDate,
        transactionsByMonth,
        context,
      );
      pdfGenerator.viewPdf(
        context,
        filePath,
        widget.selectMonth,
        transactionsByMonth,
        closingBalance,
        1,
        1,
      );
    } catch (e) {
      debugPrint("Error creating monthly payments PDF: $e");
    }
  }

  Future<void> _createMonthlyReceiptPdf(
    BuildContext context,
    DateTime selectedDate,
    PdfGenerator pdfGenerator,
    Map<String, List<TransactionModel>> transactionsByMonth,
    String pdfPath,
    double closingBalance,
  ) async {
    try {
      final filePath = await pdfGenerator.generateMonthlyReceiptsPdfReport(
        selectedDate,
        transactionsByMonth,
        context,
      );
      pdfGenerator.viewPdf(
        context,
        filePath,
        widget.selectMonth,
        transactionsByMonth,
        closingBalance,
        2,
        2,
      );
    } catch (e) {
      debugPrint("Error creating monthly receipts PDF: $e");
    }
  }

  Future<void> _createMonthlyPdf(
    BuildContext context,
    DateTime selectedDate,
    PdfGenerator pdfGenerator,
    Map<String, List<TransactionModel>> transactionsByMonth,
    double closingBalance,
    String pdfpath,
  ) async {
    try {
      final filePath = await pdfGenerator.generateMonthlyPdfReport(
        selectedDate,
        closingBalance,
        transactionsByMonth,
        context,
      );
      pdfGenerator.viewPdf(
        context,
        filePath,
        widget.selectMonth,
        transactionsByMonth,
        closingBalance,
        3,
        3,
      );
    } catch (e) {
      debugPrint("Error creating monthly PDF: $e");
    }
  }

  Future<void> _createMonthlyTransfersPdf(
    BuildContext context,
    DateTime selectedDate,
    PdfGenerator pdfGenerator,
    Map<String, List<TransactionModel>> transactionsByMonth,
    double closingBalance,
    String pdfpath,
  ) async {
    try {
      final filePath = await pdfGenerator.generateMonthlyTransfersPdfReport(
        selectedDate,
        transactionsByMonth,
        context,
      );
      pdfGenerator.viewPdf(
        context,
        filePath,
        widget.selectMonth,
        transactionsByMonth,
        closingBalance,
        3,
        3,
      );
    } catch (e) {
      debugPrint("Error creating monthly transfers PDF: $e");
    }
  }

  Widget _buildBottons(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _changeMonth(context, -1),
            child: const Icon(Icons.arrow_left),
          ),
          GestureDetector(
            onTap: () => _selectMonthYear(context),
            child: Text(
              DateFormat('MMMM y').format(widget.selectMonth),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _changeMonth(context, 1),
            child: const Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }

  Future<void> _changeMonth(BuildContext context, int change) async {
    try {
      final newDate = widget.selectMonth.add(Duration(days: 30 * change));
      setState(() {
        widget.selectMonth = newDate;
      });
      await _createMonthlyPdf(
        context,
        widget.selectMonth,
        pdfGenerator,
        widget.transactionsByMonth,
        widget.closingBalance,
        widget.pdfPath,
      );
    } catch (e) {
      debugPrint("Error changing month: $e");
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    try {
      showMonthPicker(
        context: context,
        initialDate: widget.selectMonth,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2101, 12),
      ).then((date) async {
        if (date != null) {
          setState(() {
            widget.selectMonth = date;
          });
          await _createMonthlyPdf(
            context,
            widget.selectMonth,
            pdfGenerator,
            widget.transactionsByMonth,
            widget.closingBalance,
            widget.pdfPath,
          );
        }
      });
    } catch (e) {
      debugPrint("Error selecting month/year: $e");
    }
  }
}
