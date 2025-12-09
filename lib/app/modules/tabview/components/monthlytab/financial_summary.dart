import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarima_wallet_pro/app/data/provider/currency_provider.dart';

class FinancialSummaryWidget extends StatelessWidget {
  final FinancialData data;
  final FinancialSummaryTheme theme;

  const FinancialSummaryWidget({
    super.key,
    required this.data,
    this.theme = const FinancialSummaryTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: theme.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialSummaryRow(
            label1: 'C/F:',
            value1: data.carryForward,
            label2: 'Income:',
            value2: data.totalReceipts,
            valueColor2: AppColor.kGreen,
            theme: theme,
          ),
          SizedBox(height: theme.rowSpacing),
          FinancialSummaryRow(
            label1: 'Balance:',
            value1: data.balance,
            label2: 'Expense:',
            value2: data.totalPayments,
            valueColor2: AppColor.kRed,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class FinancialSummaryRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;
  final Color? valueColor1;
  final Color? valueColor2;
  final FinancialSummaryTheme theme;

  const FinancialSummaryRow({
    super.key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    this.valueColor1,
    this.valueColor2,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FinancialSummaryText(
          label: label1,
          value: value1,
          valueColor: valueColor1,
          theme: theme,
        ),
        FinancialSummaryText(
          label: label2,
          value: value2,
          valueColor: valueColor2,
          theme: theme,
        ),
      ],
    );
  }
}

class FinancialSummaryText extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FinancialSummaryTheme theme;

  const FinancialSummaryText({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).brightness == Brightness.dark
        ? AppColor.kWhite
        : AppColor.kGrayscaleDark100;
    final currencySymbol =
        Provider.of<CurrencyNotifier>(context).currencySymbol;

    return RichText(
      text: TextSpan(
        text: '$label ',
        style: theme.labelStyle.copyWith(color: defaultColor),
        children: [
          TextSpan(
            text: '$currencySymbol $value',
            style: theme.valueStyle.copyWith(
              color: valueColor ?? defaultColor,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialData {
  final String totalReceipts;
  final String totalPayments;
  final String carryForward;
  final String balance;

  const FinancialData({
    required this.totalReceipts,
    required this.totalPayments,
    required this.carryForward,
    required this.balance,
  });
}

class FinancialSummaryTheme {
  final EdgeInsets padding;
  final double rowSpacing;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const FinancialSummaryTheme({
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.rowSpacing = 8,
    this.labelStyle = const TextStyle(
      fontFamily: 'Lato',
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    this.valueStyle = const TextStyle(
      fontFamily: 'Lato',
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  });

  FinancialSummaryTheme copyWith({
    EdgeInsets? padding,
    double? rowSpacing,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return FinancialSummaryTheme(
      padding: padding ?? this.padding,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
    );
  }
}
