import 'package:yarima_wallet_pro/app/modules/pdf/components/exports.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/yearly_pdf.dart';
import 'package:intl/intl.dart';

class CustomDateRangePDFGenerator {
  final Box<TransactionModel> transactionBox;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, Map<String, dynamic>> transactionsByMonth;
  final double closingBalance;

  CustomDateRangePDFGenerator({
    required this.transactionBox,
    required this.startDate,
    required this.endDate,
    required this.transactionsByMonth,
    required this.closingBalance,
  });

  Future<String> generateCustomDateRangePDF() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    PdfPage page = document.pages.add();

    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final String reportTitle =
        'Financial Report: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';
    final Size titleSize = titleFont.measureString(reportTitle);

    page.graphics.drawString(reportTitle, titleFont,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds:
            Rect.fromLTWH(0, 0, page.getClientSize().width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    double yOffset = titleSize.height + 20;

    final PdfGrid transactionsGrid = PdfGrid();
    transactionsGrid.columns.add(count: 6);
    transactionsGrid.headers.add(1);

    final PdfGridRow header = transactionsGrid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Type';
    header.cells[2].value = 'Category';
    header.cells[3].value = 'Description';
    header.cells[4].value = 'Account';
    header.cells[5].value = 'Amount';

    final List<TransactionModel> transactions = transactionBox.values
        .where((transaction) =>
            transaction.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    transactions.sort((a, b) => a.date.compareTo(b.date));

    double totalReceipts = 0;
    double totalPayments = 0;

    for (final transaction in transactions) {
      final PdfGridRow row = transactionsGrid.rows.add();
      row.cells[0].value = DateFormat('dd/MM/yyyy').format(transaction.date);
      row.cells[1].value = transaction.transactionType.toString().split('.').last;
      row.cells[2].value = transaction.categoryName;
      row.cells[3].value = transaction.description;
      row.cells[4].value = transaction.fromAccount;
      row.cells[5].value = transaction.amount.toStringAsFixed(2);

      if (transaction.transactionType == TransactionType.receipt) {
        totalReceipts += transaction.amount;
      } else if (transaction.transactionType == TransactionType.payment) {
        totalPayments += transaction.amount;
      }
    }

    // Add summary rows
    final PdfGridRow totalReceiptsRow = transactionsGrid.rows.add();
    totalReceiptsRow.cells[0].value = 'Total Income';
    totalReceiptsRow.cells[5].value = totalReceipts.toStringAsFixed(2);

    final PdfGridRow totalPaymentsRow = transactionsGrid.rows.add();
    totalPaymentsRow.cells[0].value = 'Total Expense';
    totalPaymentsRow.cells[5].value = totalPayments.toStringAsFixed(2);

    final PdfGridRow balanceRow = transactionsGrid.rows.add();
    balanceRow.cells[0].value = 'Balance';
    balanceRow.cells[5].value =
        (totalReceipts - totalPayments).toStringAsFixed(2);

    // Style the grid
    transactionsGrid.style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(179, 220, 255));
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    // Style summary rows
    for (final row in [totalReceiptsRow, totalPaymentsRow, balanceRow]) {
      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style.backgroundBrush =
            PdfSolidBrush(PdfColor(220, 220, 220));
        row.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10,
            style: PdfFontStyle.bold);
      }
    }

    transactionsGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath =
        '$appDocPath/custom_date_range_report_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  void viewPdf(
    BuildContext context,
    String pdfPath,
    int subIndex,
    int tabIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YearlyPdf(
          pdfPath: pdfPath,
          subIndex: subIndex,
          tabIndex: tabIndex,
          transactionsByMonth: transactionsByMonth,
          closingBalance: closingBalance,
          selectMonth: startDate,
          yearlyTransactionBox: transactionBox,
        ),
      ),
    );
  }
}
