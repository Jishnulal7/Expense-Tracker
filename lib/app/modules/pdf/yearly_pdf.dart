import 'package:yarima_wallet_pro/app/modules/pdf/components/customdate.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/yearly_pdf.dart';
import 'package:intl/intl.dart';

class YearlyPdf extends StatefulWidget {
  YearlyPdf({
    super.key,
    required this.pdfPath,
    required this.subIndex,
    required this.tabIndex,
    required this.transactionsByMonth,
    required this.closingBalance,
    required this.selectMonth,
    required this.yearlyTransactionBox,
  });

  final String pdfPath;
  DateTime selectMonth;
  final int subIndex;
  final int tabIndex;
  final Map<String, Map<String, dynamic>> transactionsByMonth;
  final double closingBalance;
  final Box<TransactionModel> yearlyTransactionBox;

  @override
  State<YearlyPdf> createState() => _YearlyPdfState();
}

class _YearlyPdfState extends State<YearlyPdf> {
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
          title: const Text('Yearly Report'),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: _buildYearlyButtons(context)),
        ),
      ),
      body: SfPdfViewer.file(File(widget.pdfPath)),
      floatingActionButton: _buildFloatingActionButtons(context),
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

  Widget _buildYearlyButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              _buildButton(
                'All',
                () async {
                  try {
                    await _createYearlyPdf();
                  } catch (e) {
                    debugPrint("Error creating yearly PDF: $e");
                  }
                },
              ),
              _buildButton(
                'Expense',
                () async {
                  try {
                    await _createYearlyPaymentPdf();
                  } catch (e) {
                    debugPrint("Error creating yearly payment PDF: $e");
                  }
                },
              ),
              _buildButton(
                'Income',
                () async {
                  try {
                    await _createYearlyReceiptPdf();
                  } catch (e) {
                    debugPrint("Error creating yearly receipt PDF: $e");
                  }
                },
              ),
              _buildButton(
                'Transfers',
                () async {
                  try {
                    await _createYearlyTransfersPdf();
                  } catch (e) {
                    debugPrint("Error creating yearly transfers PDF: $e");
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildButton('Pick a Date', () async {
                try {
                  await pickDate();
                } catch (e) {
                  debugPrint("Error picking date: $e");
                }
              }),
              _buildButton('Notes', () {
                _showTextfield(context);
              }),
              _buildYearSelector(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text),
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
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await generateFilteredPDF(context);
              } catch (e) {
                debugPrint("Error generating filtered PDF: $e");
              }
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

  Future<void> generateFilteredPDF(BuildContext context) async {
    try {
      final pdfPath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateFilteredPDF(filterController.text);

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        pdfPath,
        widget.subIndex,
        widget.tabIndex,
      );
    } catch (e) {
      debugPrint("Error generating filtered PDF: $e");
    }
  }

  Widget _buildYearSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              try {
                await _changeYear(context, -1);
              } catch (e) {
                debugPrint("Error changing year: $e");
              }
            },
            child: const Icon(Icons.arrow_left_outlined),
          ),
          SizedBox(
            child: Text(
              DateFormat('y').format(widget.selectMonth),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await _changeYear(context, 1);
              } catch (e) {
                debugPrint("Error changing year: $e");
              }
            },
            child: const Icon(Icons.arrow_right_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _createYearlyPdf() async {
    try {
      final filePath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateYearlyPDF();

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        filePath,
        widget.subIndex,
        widget.tabIndex,
      );
    } catch (e) {
      debugPrint("Error creating yearly PDF: $e");
    }
  }

  Future<void> _createYearlyPaymentPdf() async {
    try {
      final filePath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateYearlyPaymentPDF();

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        filePath,
        widget.subIndex,
        widget.tabIndex,
      );
    } catch (e) {
      debugPrint("Error creating yearly payment PDF: $e");
    }
  }

  Future<void> _changeYear(BuildContext context, int change) async {
    try {
      final newDate = DateTime(
        widget.selectMonth.year + change,
        widget.selectMonth.month,
        widget.selectMonth.day,
      );

      final filePath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: newDate,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateYearlyPDF();

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: newDate,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        filePath,
        widget.subIndex,
        widget.tabIndex,
      );

      setState(() {
        widget.selectMonth = newDate;
      });
    } catch (e) {
      debugPrint("Error changing year: $e");
    }
  }

  Future<void> _createYearlyReceiptPdf() async {
    try {
      final filePath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateYearlyReceiptsPDF();

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        filePath,
        widget.subIndex,
        widget.tabIndex,
      );
    } catch (e) {
      debugPrint("Error creating yearly receipt PDF: $e");
    }
  }

  Future<void> _createYearlyTransfersPdf() async {
    try {
      final filePath = await YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).generateYearlyTransfersPDF();

      YearlyPDFGenerator(
        yearlyTransactionBox: widget.yearlyTransactionBox,
        selectedYear: widget.selectMonth,
        yearlyData: widget.transactionsByMonth,
        closingBalance: widget.closingBalance,
      ).viewPdf(
        context,
        filePath,
        widget.subIndex,
        widget.tabIndex,
      );
    } catch (e) {
      debugPrint("Error creating yearly transfers PDF: $e");
    }
  }

  pickDate() async {
    try {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        final pdfGenerator = CustomDateRangePDFGenerator(
          closingBalance: widget.closingBalance,
          endDate: picked.end,
          startDate: picked.start,
          transactionsByMonth: widget.transactionsByMonth,
          transactionBox: widget.yearlyTransactionBox,
        );

        final pdfPath = await pdfGenerator.generateCustomDateRangePDF();

        pdfGenerator.viewPdf(
          context,
          pdfPath,
          widget.subIndex,
          widget.tabIndex,
        );
      }
    } catch (e) {
      debugPrint("Error picking date: $e");
    }
  }
}
