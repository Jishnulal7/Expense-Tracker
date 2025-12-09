import 'dart:io';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/monthly_pdf.dart';

class PdfGenerator {
  Future<String> generateMonthlyPdfReport(
    DateTime selectedMonth,
    double closingBalance,
    Map<String, List<TransactionModel>> transactionsByMonth,
    BuildContext context,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    page.graphics.drawString(
      'Monthly Transaction Report - ${DateFormat('MMMM yyyy').format(selectedMonth)}',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 8); // Added one more column for transfers
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Category';
    header.cells[2].value = 'Description';
    header.cells[3].value = 'Account';
    header.cells[4].value = 'Income';
    header.cells[5].value = 'Expense';
    header.cells[6].value = 'Transfer'; // New column for transfers
    header.cells[7].value = 'Balance';

    // final PdfGridRow cfRow = grid.rows.add();
    // cfRow.cells[0].value = 'C/F';
    // cfRow.cells[1].value = '';
    // cfRow.cells[2].value = '';
    // cfRow.cells[3].value = '';
    // cfRow.cells[4].value = '';
    // cfRow.cells[5].value = '';
    // cfRow.cells[6].value = '';
    // cfRow.cells[7].value = closingBalance.toStringAsFixed(2);

    header.style.backgroundBrush = PdfSolidBrush(PdfColor(179, 220, 255));
    header.style.textBrush = PdfBrushes.black;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);

    double runningBalance = closingBalance;
    final selectedMonthKey = DateFormat('yyyy-MM').format(selectedMonth);
    double totalReceipts = 0;
    double totalPayments = 0;
    double totalTransfers = 0;

    transactionsByMonth.forEach((date, transactions) {
      if (date.startsWith(selectedMonthKey)) {
        for (var transaction in transactions.reversed) {
          PdfGridRow row = grid.rows.add();
          row.cells[0].value =
              DateFormat('dd/MM/yyyy').format(transaction.date);
          row.cells[1].value = transaction.categoryName ?? '';
          row.cells[2].value = transaction.description;
          row.cells[3].value = transaction.fromAccount;

          switch (transaction.transactionType) {
            case TransactionType.receipt:
              row.cells[4].value = transaction.amount.toStringAsFixed(2);
              row.cells[5].value = '';
              row.cells[6].value = '';
              runningBalance -= transaction.amount;
              totalReceipts += transaction.amount;
              break;
            case TransactionType.payment:
              row.cells[4].value = '';
              row.cells[5].value = transaction.amount.toStringAsFixed(2);
              row.cells[6].value = '';
              runningBalance += transaction.amount;
              totalPayments += transaction.amount;
              break;
            case TransactionType.transfer:
              row.cells[4].value = '';
              row.cells[5].value = '';
              row.cells[6].value = transaction.amount.toStringAsFixed(2);
              totalTransfers += transaction.amount;
              // Note: Transfers don't affect the running balance
              break;
          }

          row.cells[7].value = runningBalance.toStringAsFixed(2);
        }
      }
    });

    // Add total row
    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[0].value = 'Totals';
    totalRow.cells[4].value = totalReceipts.toStringAsFixed(2);
    totalRow.cells[5].value = totalPayments.toStringAsFixed(2);
    totalRow.cells[6].value = totalTransfers.toStringAsFixed(2);
    totalRow.cells[7].value = runningBalance.toStringAsFixed(2);

    // Style the total row
    PdfGridCellStyle totalRowStyle = PdfGridCellStyle();
    totalRowStyle.backgroundBrush = PdfSolidBrush(PdfColor(200, 200, 200));
    totalRowStyle.font =
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    for (int i = 0; i < totalRow.cells.count; i++) {
      totalRow.cells[i].style = totalRowStyle;
    }

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 3, bottom: 3);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height - 50),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName =
        'Monthly_Report_${DateFormat('MMM_yyyy').format(selectedMonth)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  Future<String> generateMonthlyReceiptsPdfReport(
    DateTime selectedMonth,
    Map<String, List<TransactionModel>> transactionsByMonth,
    BuildContext context,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Add title to the page
    page.graphics.drawString(
      'Monthly Receipts Report - ${DateFormat('MMMM yyyy').format(selectedMonth)}',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Category';
    header.cells[2].value = 'Description';
    header.cells[3].value = 'Account';
    header.cells[4].value = 'Amount';

    header.style.backgroundBrush = PdfSolidBrush(PdfColor(179, 220, 255));
    header.style.textBrush = PdfBrushes.black;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final selectedMonthKey = DateFormat('yyyy-MM').format(selectedMonth);
    double totalAmount = 0;

    transactionsByMonth.forEach((date, transactions) {
      if (date.startsWith(selectedMonthKey)) {
        for (var transaction in transactions) {
          if (transaction.transactionType == TransactionType.receipt) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value =
                DateFormat('dd/MM/yyyy').format(transaction.date);
            row.cells[1].value = transaction.categoryName ?? '';
            row.cells[2].value = transaction.description;
            row.cells[3].value = transaction.fromAccount;
            row.cells[4].value = transaction.amount.toStringAsFixed(2);
            totalAmount += transaction.amount;
          }
        }
      }
    });

    // Add total row
    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[3].value = 'Total Receipts:';
    totalRow.cells[4].value = totalAmount.toStringAsFixed(2);
    totalRow.style.backgroundBrush = PdfSolidBrush(PdfColor(200, 200, 200));
    totalRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 3, bottom: 3);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height - 50),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName =
        'Monthly_Receipts_${DateFormat('MMM_yyyy').format(selectedMonth)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  Future<String> generateMonthlyTransfersPdfReport(
    DateTime selectedMonth,
    Map<String, List<TransactionModel>> transactionsByMonth,
    BuildContext context,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Add title to the page
    page.graphics.drawString(
      'Monthly Transfers Report - ${DateFormat('MMMM yyyy').format(selectedMonth)}',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Description';
    header.cells[2].value = 'From Account';
    header.cells[3].value = 'To Account';
    header.cells[4].value = 'Amount';

    header.style.backgroundBrush = PdfSolidBrush(PdfColor(179, 220, 255));
    header.style.textBrush = PdfBrushes.black;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final selectedMonthKey = DateFormat('yyyy-MM').format(selectedMonth);
    double totalAmount = 0;

    transactionsByMonth.forEach((date, transactions) {
      if (date.startsWith(selectedMonthKey)) {
        for (var transaction in transactions) {
          if (transaction.transactionType == TransactionType.transfer) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value =
                DateFormat('dd/MM/yyyy').format(transaction.date);
            row.cells[1].value = transaction.description;
            row.cells[2].value = transaction.fromAccount;
            row.cells[3].value = transaction.toAccount;
            row.cells[4].value = transaction.amount.toStringAsFixed(2);
            totalAmount += transaction.amount;
          }
        }
      }
    });

    // Add total row
    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[3].value = 'Total Transfers:';
    totalRow.cells[4].value = totalAmount.toStringAsFixed(2);
    totalRow.style.backgroundBrush = PdfSolidBrush(PdfColor(200, 200, 200));
    totalRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 3, bottom: 3);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height - 50),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName =
        'Monthly_Transfers_${DateFormat('MMM_yyyy').format(selectedMonth)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  Future<String> generateMonthlyPaymentsPdfReport(
    DateTime selectedMonth,
    Map<String, List<TransactionModel>> transactionsByMonth,
    BuildContext context,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Add title to the page
    page.graphics.drawString(
      'Monthly Expense Report - ${DateFormat('MMMM yyyy').format(selectedMonth)}',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Category';
    header.cells[2].value = 'Description';
    header.cells[3].value = 'Account';
    header.cells[4].value = 'Amount';

    header.style.backgroundBrush = PdfSolidBrush(PdfColor(179, 220, 255));
    header.style.textBrush = PdfBrushes.black;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final selectedMonthKey = DateFormat('yyyy-MM').format(selectedMonth);
    double totalPayments = 0;

    transactionsByMonth.forEach((date, transactions) {
      if (date.startsWith(selectedMonthKey)) {
        for (var transaction in transactions) {
          if (transaction.transactionType == TransactionType.payment) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value =
                DateFormat('dd/MM/yyyy').format(transaction.date);
            row.cells[1].value = transaction.categoryName ?? '';
            row.cells[2].value = transaction.description;
            row.cells[3].value = transaction.fromAccount;
            row.cells[4].value = transaction.amount.toStringAsFixed(2);
            totalPayments += transaction.amount;
          }
        }
      }
    });

    // Add total row
    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[3].value = 'Total Expense:';
    totalRow.cells[4].value = totalPayments.toStringAsFixed(2);
    totalRow.style.backgroundBrush = PdfSolidBrush(PdfColor(200, 200, 200));
    totalRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 3, bottom: 3);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height - 50),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName =
        'Monthly_Expense_${DateFormat('MMM_yyyy').format(selectedMonth)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  Future<String> generateFilteredPdfReport(
    DateTime selectedMonth,
    Map<String, List<TransactionModel>> transactionsByMonth,
    String filter,
    BuildContext context,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    page.graphics.drawString(
      'Filtered Transaction Report - ${DateFormat('MMMM yyyy').format(selectedMonth)}',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Category';
    header.cells[2].value = 'Description';
    header.cells[3].value = 'Account';
    header.cells[4].value = 'Type';
    header.cells[5].value = 'Amount';

    header.style.backgroundBrush = PdfSolidBrush(PdfColor(179, 220, 255));
    header.style.textBrush = PdfBrushes.black;
    header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final selectedMonthKey = DateFormat('yyyy-MM').format(selectedMonth);

    transactionsByMonth.forEach((date, transactions) {
      if (date.startsWith(selectedMonthKey)) {
        for (var transaction in transactions) {
          if (transaction.description
              .toLowerCase()
              .contains(filter.toLowerCase())) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value =
                DateFormat('dd/MM/yyyy').format(transaction.date);
            row.cells[1].value = transaction.categoryName ?? '';
            row.cells[2].value = transaction.description;
            row.cells[3].value = transaction.fromAccount;
            row.cells[4].value = transaction.transactionType.toString().split('.').last;
            row.cells[5].value = transaction.amount.toStringAsFixed(2);
          }
        }
      }
    });

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 3, bottom: 3);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height - 50),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName =
        'Filtered_Report_${DateFormat('MMM_yyyy').format(selectedMonth)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  void viewPdf(
    BuildContext context,
    String pdfPath,
    DateTime selectedMonth,
    Map<String, List<TransactionModel>> transactionsByMonth,
    double closingBalance,
    int subIndex,
    int tabIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyPdf(
          pdfPath: pdfPath,
          selectMonth: selectedMonth,
          subIndex: subIndex,
          tabIndex: tabIndex,
          transactionsByMonth: transactionsByMonth,
          closingBalance: closingBalance,
        ),
      ),
    );
  }
}
