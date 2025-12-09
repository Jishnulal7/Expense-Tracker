import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/components/pdf_downloader.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/components/exports.dart';
import 'package:intl/intl.dart';

class PdfViewScreen extends StatefulWidget {
  final String accountName;
  final List<TransactionModel> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const PdfViewScreen({
    super.key,
    required this.accountName,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.accountName} Transactions'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SpeedDial(
            heroTag: 'download',
            onPress: () async {
              final pdfBytes = await _generatePdfBytes();
              await PdfDownloader()
                  .downloadPdf(context, pdfBytes, widget.accountName);
            },
            child: const Icon(Icons.download),
          ),
          const SizedBox(width: 10),
          SpeedDial(
            heroTag: 'share',
            onPress: () async {
              final pdfBytes = await _generatePdfBytes();
              await PdfDownloader().sharePdf(pdfBytes, widget.accountName);
            },
            child: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder<PdfDocument>(
        future: _generatePdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error generating PDF'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No PDF data available'));
          }
          final Uint8List pdfBytes =
              Uint8List.fromList(snapshot.data!.saveSync());
          return SfPdfViewer.memory(pdfBytes, key: UniqueKey());
        },
      ),
    );
  }

  Future<Uint8List> _generatePdfBytes() async {
    final document = await _generatePdf();
    return Uint8List.fromList(document.saveSync());
  }

  Future<PdfDocument> _generatePdf() async {
    final document = PdfDocument();
    final page = document.pages.add();

    _addStylishHeader(page);
    _addTransactionTable(page);

    return document;
  }

  void _addStylishHeader(PdfPage page) {
    final headerText = PdfTextElement(
      text: 'Transactions for ${widget.accountName}',
      font: PdfStandardFont(PdfFontFamily.helvetica, 24,
          style: PdfFontStyle.bold),
    );
    headerText.draw(page: page, bounds: const Rect.fromLTWH(0, 0, 0, 0));

    final dateRangeText = PdfTextElement(
      text:
          'From ${DateFormat('dd MMM yyyy').format(widget.startDate)} to ${DateFormat('dd MMM yyyy').format(widget.endDate)}',
      font: PdfStandardFont(PdfFontFamily.helvetica, 14),
    );
    dateRangeText.draw(page: page, bounds: const Rect.fromLTWH(0, 30, 0, 0));

    final graphics = page.graphics;
    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1),
      const Offset(0, 55),
      Offset(page.getClientSize().width, 55),
    );
  }

  PdfLayoutResult _addTransactionTable(PdfPage page) {
    final header = [
      'Date',
      'Category',
      'Description',
      'Income',
      'Expense',
      'Balance'
    ];

    final filteredTransactions = widget.transactions
        .where((transaction) =>
            (transaction.fromAccount == widget.accountName ||
                transaction.toAccount == widget.accountName) &&
            transaction.date
                .isAfter(widget.startDate.subtract(const Duration(days: 1))) &&
            transaction.date
                .isBefore(widget.endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final table = PdfGrid();
    table.columns.add(count: header.length);
    table.headers.add(1);
    final headerRow = table.headers[0];
    for (int i = 0; i < header.length; i++) {
      headerRow.cells[i].value = header[i];
      headerRow.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(66, 133, 244));
      headerRow.cells[i].style.textBrush = PdfBrushes.white;
      headerRow.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
    }

    double runningBalance = 0;
    double totalReceipts = 0;
    double totalPayments = 0;

    for (var transaction in filteredTransactions) {
      final row = table.rows.add();
      row.cells[0].value = DateFormat('dd MMM yyyy').format(transaction.date);
      row.cells[1].value = transaction.categoryName ?? '';
      row.cells[2].value = transaction.description;

      final isReceipt = transaction.transactionType == TransactionType.receipt ||
          (transaction.transactionType == TransactionType.transfer &&
              transaction.toAccount == widget.accountName);
      final isPayment = transaction.transactionType == TransactionType.payment ||
          (transaction.transactionType == TransactionType.transfer &&
              transaction.fromAccount == widget.accountName);

      final amount = transaction.amount.abs().toStringAsFixed(2);
      if (isReceipt) {
        row.cells[3].value = amount;
        totalReceipts += transaction.amount;
      } else {
        row.cells[3].value = '';
      }
      if (isPayment) {
        row.cells[4].value = amount;
        totalPayments += transaction.amount;
      } else {
        row.cells[4].value = '';
      }

      runningBalance += isReceipt ? transaction.amount : -transaction.amount;
      row.cells[5].value = runningBalance.toStringAsFixed(2);
    }

    for (int i = 0; i < table.rows.count; i++) {
      final row = table.rows[i];
      final brush = i % 2 == 0
          ? PdfSolidBrush(PdfColor(242, 242, 242))
          : PdfSolidBrush(PdfColor(255, 255, 255));
      for (int j = 0; j < row.cells.count; j++) {
        row.cells[j].style.backgroundBrush = brush;
      }
    }

    final summaryRow = table.rows.add();
    summaryRow.cells[0].value = 'Total';
    summaryRow.cells[1].value = '';
    summaryRow.cells[2].value = '';
    summaryRow.cells[3].value = totalReceipts.toStringAsFixed(2);
    summaryRow.cells[4].value = totalPayments.toStringAsFixed(2);
    summaryRow.cells[5].value = runningBalance.toStringAsFixed(2);

    for (int i = 0; i < summaryRow.cells.count; i++) {
      summaryRow.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(200, 200, 200));
      summaryRow.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    return table.draw(
        page: page,
        bounds: Rect.fromLTWH(0, 70, page.getClientSize().width,
            page.getClientSize().height - 70))!;
  }
}
