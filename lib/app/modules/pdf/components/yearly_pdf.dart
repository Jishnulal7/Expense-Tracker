import 'dart:io';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/pdf/yearly_pdf.dart';
import 'package:yarima_wallet_pro/app/modules/tabview/yearlytab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:hive/hive.dart';

class YearlyPDFGenerator {
  final Box<TransactionModel> yearlyTransactionBox;
  final DateTime selectedYear;
  final Map<String, Map<String, dynamic>> yearlyData;
  final double closingBalance;

  YearlyPDFGenerator({
    required this.yearlyTransactionBox,
    required this.selectedYear,
    required this.yearlyData,
    required this.closingBalance,
  });

  Future<String> generateYearlyPDF() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    PdfPage page = document.pages.add();

    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final Size titleSize =
        titleFont.measureString('Yearly Financial Report ${selectedYear.year}');
    page.graphics.drawString(
        'Yearly Financial Report ${selectedYear.year}', titleFont,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds:
            Rect.fromLTWH(0, 0, page.getClientSize().width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    double yOffset = titleSize.height + 20;

    final PdfGrid yearlyGrid = PdfGrid();
    yearlyGrid.columns.add(count: 5); // Added one more column for transfers
    yearlyGrid.headers.add(1);

    final PdfGridRow yearlyHeader = yearlyGrid.headers[0];
    yearlyHeader.cells[0].value = 'Month';
    yearlyHeader.cells[1].value = 'Total Income';
    yearlyHeader.cells[2].value = 'Total Expense';
    yearlyHeader.cells[3].value = 'Total Transfers'; // New column for transfers
    yearlyHeader.cells[4].value = 'Balance';

    double yearlyTotalReceipts = 0;
    double yearlyTotalPayments = 0;
    double yearlyTotalTransfers = 0; // New variable for total transfers
    double yearlyBalance = 0;

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      final PdfGridRow row = yearlyGrid.rows.add();
      row.cells[0].value = month;

      double monthlyReceipts =
          data != null ? double.parse(data['totalReceipts'].toString()) : 0;
      double monthlyPayments =
          data != null ? double.parse(data['totalPayments'].toString()) : 0;
      double monthlyTransfers =
          data != null ? double.parse(data['totalTransfers'].toString()) : 0;
      double monthlyBalance = monthlyReceipts - monthlyPayments;

      yearlyTotalReceipts += monthlyReceipts;
      yearlyTotalPayments += monthlyPayments;
      yearlyTotalTransfers += monthlyTransfers; // Add to yearly total transfers
      yearlyBalance += monthlyBalance;

      row.cells[1].value = monthlyReceipts.toStringAsFixed(2);
      row.cells[2].value = monthlyPayments.toStringAsFixed(2);
      row.cells[3].value =
          monthlyTransfers.toStringAsFixed(2); // Add transfers to the row
      row.cells[4].value = monthlyBalance.toStringAsFixed(2);
    }

    // Add yearly total row
    final PdfGridRow yearlyTotalRow = yearlyGrid.rows.add();
    yearlyTotalRow.cells[0].value = 'Yearly Total';
    yearlyTotalRow.cells[1].value = yearlyTotalReceipts.toStringAsFixed(2);
    yearlyTotalRow.cells[2].value = yearlyTotalPayments.toStringAsFixed(2);
    yearlyTotalRow.cells[3].value =
        yearlyTotalTransfers.toStringAsFixed(2); // Add total transfers
    yearlyTotalRow.cells[4].value = yearlyBalance.toStringAsFixed(2);

    // Style the yearly total row
    for (int i = 0; i < yearlyTotalRow.cells.count; i++) {
      yearlyTotalRow.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(220, 220, 220));
      yearlyTotalRow.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    yearlyGrid.style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    for (int i = 0; i < yearlyHeader.cells.count; i++) {
      yearlyHeader.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(179, 220, 255));
      yearlyHeader.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    PdfLayoutResult yearlyGridResult = yearlyGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    )!;

    // Add total yearly balance
    yOffset = yearlyGridResult.bounds.bottom + 20;
    page.graphics.drawString(
        'Total Yearly Balance: ${yearlyBalance.toStringAsFixed(2)}',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      if (data != null) {
        page = document.pages.add();
        yOffset = 20;

        final PdfFont monthFont = PdfStandardFont(PdfFontFamily.helvetica, 16,
            style: PdfFontStyle.bold);
        final Size monthSize = monthFont.measureString(monthYear);
        page.graphics.drawString(monthYear, monthFont,
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(
                0, yOffset, page.getClientSize().width, monthSize.height),
            format: PdfStringFormat(alignment: PdfTextAlignment.center));
        yOffset += monthSize.height + 20;

        final PdfGrid monthlyGrid = PdfGrid();
        monthlyGrid.columns
            .add(count: 8); // Added one more column for transfers
        monthlyGrid.headers.add(1);

        final PdfGridRow monthlyHeader = monthlyGrid.headers[0];
        monthlyHeader.cells[0].value = 'Date';
        monthlyHeader.cells[1].value = 'Category';
        monthlyHeader.cells[2].value = 'Description';
        monthlyHeader.cells[3].value = 'Account';
        monthlyHeader.cells[4].value = 'Income';
        monthlyHeader.cells[5].value = 'Expense';
        monthlyHeader.cells[6].value = 'Transfer'; // New column for transfers
        monthlyHeader.cells[7].value = 'Balance';

        // final PdfGridRow cfRow = monthlyGrid.rows.add();
        // cfRow.cells[0].value = 'C/F';
        // cfRow.cells[1].value = '';
        // cfRow.cells[2].value = '';
        // cfRow.cells[3].value = '';
        // cfRow.cells[4].value = '';
        // cfRow.cells[5].value = '';
        // cfRow.cells[6].value = '';
        // cfRow.cells[7].value = closingBalance.toStringAsFixed(2);

        final monthIndex = YearlyTab.monthIndexMapping[month]!;
        final monthStart = DateTime(selectedYear.year, monthIndex, 1);
        final monthEnd = DateTime(selectedYear.year, monthIndex + 1, 0);

        final List<TransactionModel> transactions = yearlyTransactionBox.values
            .where((transaction) =>
                transaction.date
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                transaction.date
                    .isBefore(monthEnd.add(const Duration(days: 1))))
            .toList();

        transactions.sort((a, b) => a.date.compareTo(b.date));

        double runningBalance = 0;
        double totalReceipts = 0;
        double totalPayments = 0;
        double totalTransfers = 0; // New variable for total transfers

        for (final transaction in transactions) {
          final PdfGridRow row = monthlyGrid.rows.add();
          row.cells[0].value =
              DateFormat('dd/MM/yyyy').format(transaction.date);
          row.cells[1].value = transaction.categoryName;
          row.cells[2].value = transaction.description;
          row.cells[3].value = transaction.fromAccount;

          if (transaction.transactionType == TransactionType.receipt) {
            row.cells[4].value = transaction.amount.toStringAsFixed(2);
            row.cells[5].value = '-';
            row.cells[6].value = '-';
            runningBalance += transaction.amount;
            totalReceipts += transaction.amount;
          } else if (transaction.transactionType == TransactionType.payment) {
            row.cells[4].value = '-';
            row.cells[5].value = transaction.amount.toStringAsFixed(2);
            row.cells[6].value = '-';
            runningBalance -= transaction.amount;
            totalPayments += transaction.amount;
          } else if (transaction.transactionType == TransactionType.transfer) {
            row.cells[4].value = '-';
            row.cells[5].value = '-';
            row.cells[6].value = transaction.amount.toStringAsFixed(2);
            totalTransfers += transaction.amount;
            // Note: Transfers don't affect the running balance
          }

          row.cells[7].value = runningBalance.toStringAsFixed(2);
        }

        // Add summary row
        final PdfGridRow summaryRow = monthlyGrid.rows.add();
        summaryRow.cells[0].value = 'Total';
        summaryRow.cells[1].value = '';
        summaryRow.cells[2].value = '';
        summaryRow.cells[3].value = '';
        summaryRow.cells[4].value = totalReceipts.toStringAsFixed(2);
        summaryRow.cells[5].value = totalPayments.toStringAsFixed(2);
        summaryRow.cells[6].value =
            totalTransfers.toStringAsFixed(2); // Add total transfers
        summaryRow.cells[7].value = runningBalance.toStringAsFixed(2);

        // Style the summary row
        for (int i = 0; i < summaryRow.cells.count; i++) {
          summaryRow.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(220, 220, 220));
          summaryRow.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.style.cellPadding =
            PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
        for (int i = 0; i < monthlyHeader.cells.count; i++) {
          monthlyHeader.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(179, 220, 255));
          monthlyHeader.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        PdfLayoutResult result = monthlyGrid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
        )!;

        // Add monthly summary text
        yOffset = result.bounds.bottom + 10;
      }
    }

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath =
        '$appDocPath/yearly_report_${selectedYear.year}.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> generateYearlyPaymentPDF() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    PdfPage page = document.pages.add();

    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final Size titleSize =
        titleFont.measureString('Yearly Payment Report ${selectedYear.year}');
    page.graphics.drawString(
        'Yearly Payment Report ${selectedYear.year}', titleFont,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds:
            Rect.fromLTWH(0, 0, page.getClientSize().width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    double yOffset = titleSize.height + 20;

    final PdfGrid yearlyGrid = PdfGrid();
    yearlyGrid.columns.add(count: 2);
    yearlyGrid.headers.add(1);

    final PdfGridRow yearlyHeader = yearlyGrid.headers[0];
    yearlyHeader.cells[0].value = 'Month';
    yearlyHeader.cells[1].value = 'Total Payments';

    double yearlyTotalPayments = 0;

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      final PdfGridRow row = yearlyGrid.rows.add();
      row.cells[0].value = month;

      double monthlyPayments =
          data != null ? double.parse(data['totalPayments'].toString()) : 0;

      yearlyTotalPayments += monthlyPayments;

      row.cells[1].value = monthlyPayments.toStringAsFixed(2);
    }

    // Add yearly total row
    final PdfGridRow yearlyTotalRow = yearlyGrid.rows.add();
    yearlyTotalRow.cells[0].value = 'Yearly Total';
    yearlyTotalRow.cells[1].value = yearlyTotalPayments.toStringAsFixed(2);

    // Style the yearly total row
    for (int i = 0; i < yearlyTotalRow.cells.count; i++) {
      yearlyTotalRow.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(220, 220, 220));
      yearlyTotalRow.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    yearlyGrid.style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    for (int i = 0; i < yearlyHeader.cells.count; i++) {
      yearlyHeader.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(179, 220, 255));
      yearlyHeader.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    PdfLayoutResult yearlyGridResult = yearlyGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    )!;

    // Add total yearly payments
    yOffset = yearlyGridResult.bounds.bottom + 20;
    page.graphics.drawString(
        'Total Yearly Payments: ${yearlyTotalPayments.toStringAsFixed(2)}',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      if (data != null) {
        page = document.pages.add();
        yOffset = 20;

        final PdfFont monthFont = PdfStandardFont(PdfFontFamily.helvetica, 16,
            style: PdfFontStyle.bold);
        final Size monthSize = monthFont.measureString(monthYear);
        page.graphics.drawString(monthYear, monthFont,
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(
                0, yOffset, page.getClientSize().width, monthSize.height),
            format: PdfStringFormat(alignment: PdfTextAlignment.center));
        yOffset += monthSize.height + 20;

        final PdfGrid monthlyGrid = PdfGrid();
        monthlyGrid.columns.add(count: 5);
        monthlyGrid.headers.add(1);

        final PdfGridRow monthlyHeader = monthlyGrid.headers[0];
        monthlyHeader.cells[0].value = 'Date';
        monthlyHeader.cells[1].value = 'Category';
        monthlyHeader.cells[2].value = 'Description';
        monthlyHeader.cells[3].value = 'Account';
        monthlyHeader.cells[4].value = 'Payment';

        final monthIndex = YearlyTab.monthIndexMapping[month]!;
        final monthStart = DateTime(selectedYear.year, monthIndex, 1);
        final monthEnd = DateTime(selectedYear.year, monthIndex + 1, 0);

        final List<TransactionModel> transactions = yearlyTransactionBox.values
            .where((transaction) =>
                transaction.date
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                transaction.date
                    .isBefore(monthEnd.add(const Duration(days: 1))) &&
                transaction.transactionType == TransactionType.payment)
            .toList();

        transactions.sort((a, b) => a.date.compareTo(b.date));

        double totalPayments = 0;

        for (final transaction in transactions) {
          final PdfGridRow row = monthlyGrid.rows.add();
          row.cells[0].value =
              DateFormat('dd/MM/yyyy').format(transaction.date);
          row.cells[1].value = transaction.categoryName;
          row.cells[2].value = transaction.description;
          row.cells[3].value = transaction.fromAccount;
          row.cells[4].value = transaction.amount.toStringAsFixed(2);

          totalPayments += transaction.amount;
        }

        // Add summary row
        final PdfGridRow summaryRow = monthlyGrid.rows.add();
        summaryRow.cells[0].value = 'Monthly Total';
        summaryRow.cells[1].value = '';
        summaryRow.cells[2].value = '';
        summaryRow.cells[3].value = '';
        summaryRow.cells[4].value = totalPayments.toStringAsFixed(2);

        // Style the summary row
        for (int i = 0; i < summaryRow.cells.count; i++) {
          summaryRow.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(220, 220, 220));
          summaryRow.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.style.cellPadding =
            PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
        for (int i = 0; i < monthlyHeader.cells.count; i++) {
          monthlyHeader.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(179, 220, 255));
          monthlyHeader.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
        );
      }
    }

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath =
        '$appDocPath/yearly_payment_report_${selectedYear.year}.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> generateYearlyReceiptsPDF() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    PdfPage page = document.pages.add();

    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final Size titleSize =
        titleFont.measureString('Yearly Receipts Report ${selectedYear.year}');
    page.graphics.drawString(
        'Yearly Receipts Report ${selectedYear.year}', titleFont,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds:
            Rect.fromLTWH(0, 0, page.getClientSize().width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    double yOffset = titleSize.height + 20;

    final PdfGrid yearlyGrid = PdfGrid();
    yearlyGrid.columns.add(count: 2);
    yearlyGrid.headers.add(1);

    final PdfGridRow yearlyHeader = yearlyGrid.headers[0];
    yearlyHeader.cells[0].value = 'Month';
    yearlyHeader.cells[1].value = 'Total Receipts';

    double yearlyTotalReceipts = 0;

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      final PdfGridRow row = yearlyGrid.rows.add();
      row.cells[0].value = month;

      double monthlyReceipts =
          data != null ? double.parse(data['totalReceipts'].toString()) : 0;

      yearlyTotalReceipts += monthlyReceipts;

      row.cells[1].value = monthlyReceipts.toStringAsFixed(2);
    }

    // Add yearly total row
    final PdfGridRow yearlyTotalRow = yearlyGrid.rows.add();
    yearlyTotalRow.cells[0].value = 'Yearly Total';
    yearlyTotalRow.cells[1].value = yearlyTotalReceipts.toStringAsFixed(2);

    // Style the yearly total row
    for (int i = 0; i < yearlyTotalRow.cells.count; i++) {
      yearlyTotalRow.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(220, 220, 220));
      yearlyTotalRow.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    yearlyGrid.style.cellPadding =
        PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    for (int i = 0; i < yearlyHeader.cells.count; i++) {
      yearlyHeader.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(179, 220, 255));
      yearlyHeader.cells[i].style.font = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    PdfLayoutResult yearlyGridResult = yearlyGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    )!;

    // Add total yearly receipts
    yOffset = yearlyGridResult.bounds.bottom + 20;
    page.graphics.drawString(
        'Total Yearly Receipts: ${yearlyTotalReceipts.toStringAsFixed(2)}',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      if (data != null) {
        page = document.pages.add();
        yOffset = 20;

        final PdfFont monthFont = PdfStandardFont(PdfFontFamily.helvetica, 16,
            style: PdfFontStyle.bold);
        final Size monthSize = monthFont.measureString(monthYear);
        page.graphics.drawString(monthYear, monthFont,
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(
                0, yOffset, page.getClientSize().width, monthSize.height),
            format: PdfStringFormat(alignment: PdfTextAlignment.center));
        yOffset += monthSize.height + 20;

        final PdfGrid monthlyGrid = PdfGrid();
        monthlyGrid.columns.add(count: 5);
        monthlyGrid.headers.add(1);

        final PdfGridRow monthlyHeader = monthlyGrid.headers[0];
        monthlyHeader.cells[0].value = 'Date';
        monthlyHeader.cells[1].value = 'Category';
        monthlyHeader.cells[2].value = 'Description';
        monthlyHeader.cells[3].value = 'Account';
        monthlyHeader.cells[4].value = 'Receipt';

        final monthIndex = YearlyTab.monthIndexMapping[month]!;
        final monthStart = DateTime(selectedYear.year, monthIndex, 1);
        final monthEnd = DateTime(selectedYear.year, monthIndex + 1, 0);

        final List<TransactionModel> transactions = yearlyTransactionBox.values
            .where((transaction) =>
                transaction.date
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                transaction.date
                    .isBefore(monthEnd.add(const Duration(days: 1))) &&
                transaction.transactionType == TransactionType.receipt)
            .toList();

        transactions.sort((a, b) => a.date.compareTo(b.date));

        double totalReceipts = 0;

        for (final transaction in transactions) {
          final PdfGridRow row = monthlyGrid.rows.add();
          row.cells[0].value =
              DateFormat('dd/MM/yyyy').format(transaction.date);
          row.cells[1].value = transaction.categoryName;
          row.cells[2].value = transaction.description;
          row.cells[3].value = transaction.fromAccount;
          row.cells[4].value = transaction.amount.toStringAsFixed(2);

          totalReceipts += transaction.amount;
        }

        // Add summary row
        final PdfGridRow summaryRow = monthlyGrid.rows.add();
        summaryRow.cells[0].value = 'Monthly Total';
        summaryRow.cells[1].value = '';
        summaryRow.cells[2].value = '';
        summaryRow.cells[3].value = '';
        summaryRow.cells[4].value = totalReceipts.toStringAsFixed(2);

        // Style the summary row
        for (int i = 0; i < summaryRow.cells.count; i++) {
          summaryRow.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(220, 220, 220));
          summaryRow.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.style.cellPadding =
            PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
        for (int i = 0; i < monthlyHeader.cells.count; i++) {
          monthlyHeader.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(179, 220, 255));
          monthlyHeader.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
        );
      }
    }

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath =
        '$appDocPath/yearly_receipts_report_${selectedYear.year}.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> generateYearlyTransfersPDF() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    for (final month in YearlyTab.orderedMonths) {
      final monthYear = '$month ${selectedYear.year}';
      final data = yearlyData[monthYear];
      if (data != null) {
        PdfPage page = document.pages.add();
        double yOffset = 20;

        final PdfFont monthFont = PdfStandardFont(PdfFontFamily.helvetica, 16,
            style: PdfFontStyle.bold);
        final Size monthSize = monthFont.measureString(monthYear);
        page.graphics.drawString(monthYear, monthFont,
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(
                0, yOffset, page.getClientSize().width, monthSize.height),
            format: PdfStringFormat(alignment: PdfTextAlignment.center));
        yOffset += monthSize.height + 20;

        final PdfGrid monthlyGrid = PdfGrid();
        monthlyGrid.columns.add(count: 5);
        monthlyGrid.headers.add(1);

        final PdfGridRow monthlyHeader = monthlyGrid.headers[0];
        monthlyHeader.cells[0].value = 'Date';
        monthlyHeader.cells[1].value = 'Description';
        monthlyHeader.cells[2].value = 'From Account';
        monthlyHeader.cells[3].value = 'To Account';
        monthlyHeader.cells[4].value = 'Amount';

        final monthIndex = YearlyTab.monthIndexMapping[month]!;
        final monthStart = DateTime(selectedYear.year, monthIndex, 1);
        final monthEnd = DateTime(selectedYear.year, monthIndex + 1, 0);

        final List<TransactionModel> transactions = yearlyTransactionBox.values
            .where((transaction) =>
                transaction.date
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                transaction.date
                    .isBefore(monthEnd.add(const Duration(days: 1))) &&
                transaction.transactionType == TransactionType.transfer)
            .toList();

        transactions.sort((a, b) => a.date.compareTo(b.date));

        double totalReceipts = 0;

        for (final transaction in transactions) {
          final PdfGridRow row = monthlyGrid.rows.add();
          row.cells[0].value =
              DateFormat('dd/MM/yyyy').format(transaction.date);
          row.cells[1].value = transaction.description;
          row.cells[2].value = transaction.fromAccount;
          row.cells[3].value = transaction.toAccount;
          row.cells[4].value = transaction.amount.toStringAsFixed(2);

          totalReceipts += transaction.amount;
        }

        // Add summary row
        final PdfGridRow summaryRow = monthlyGrid.rows.add();
        summaryRow.cells[0].value = 'Monthly Total';
        summaryRow.cells[1].value = '';
        summaryRow.cells[2].value = '';
        summaryRow.cells[3].value = '';
        summaryRow.cells[4].value = totalReceipts.toStringAsFixed(2);

        // Style the summary row
        for (int i = 0; i < summaryRow.cells.count; i++) {
          summaryRow.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(220, 220, 220));
          summaryRow.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.style.cellPadding =
            PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
        for (int i = 0; i < monthlyHeader.cells.count; i++) {
          monthlyHeader.cells[i].style.backgroundBrush =
              PdfSolidBrush(PdfColor(179, 220, 255));
          monthlyHeader.cells[i].style.font = PdfStandardFont(
              PdfFontFamily.helvetica, 10,
              style: PdfFontStyle.bold);
        }

        monthlyGrid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
        );
      }
    }

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath =
        '$appDocPath/yearly_receipts_report_${selectedYear.year}.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> generateFilteredPDF(String filterText) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    PdfPage page = document.pages.add();

    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final Size titleSize =
        titleFont.measureString('Filtered Transactions Report');
    page.graphics.drawString('Filtered Transactions Report', titleFont,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds:
            Rect.fromLTWH(0, 0, page.getClientSize().width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    double yOffset = titleSize.height + 20;

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    grid.headers.add(1);

    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Description';
    header.cells[2].value = 'Category';
    header.cells[3].value = 'Account';
    header.cells[4].value = 'Type';
    header.cells[5].value = 'Amount';

    final List<TransactionModel> filteredTransactions = yearlyTransactionBox
        .values
        .where((transaction) => transaction.description
            .toLowerCase()
            .contains(filterText.toLowerCase()))
        .toList();

    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    for (final transaction in filteredTransactions) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = DateFormat('dd/MM/yyyy').format(transaction.date);
      row.cells[1].value = transaction.description;
      row.cells[2].value = transaction.categoryName;
      row.cells[3].value = transaction.fromAccount;
      row.cells[4].value = transaction.transactionType.toString().split('.').last;
      row.cells[5].value = transaction.amount.toStringAsFixed(2);
    }

    grid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(179, 220, 255));
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
    }

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    );

    List<int> bytes = await document.save();
    document.dispose();

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    final String filePath = '$appDocPath/filtered_transactions_report.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  void viewPdf(
      BuildContext context, String pdfPath, int subIndex, int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YearlyPdf(
          pdfPath: pdfPath,
          subIndex: subIndex,
          tabIndex: tabIndex,
          transactionsByMonth: yearlyData,
          closingBalance: closingBalance,
          selectMonth: selectedYear,
          yearlyTransactionBox: yearlyTransactionBox,
        ),
      ),
    );
  }
}
