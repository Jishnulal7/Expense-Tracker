import 'package:yarima_wallet_pro/app/data/helpers/color_helper.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/category/components/category_listtile.dart';
import 'package:flutter/material.dart';
import 'package:yarima_wallet_pro/app/modules/category/components/category_helper.dart';
import 'package:hive/hive.dart';
import 'package:yarima_wallet_pro/app/modules/category/components/category_mixin.dart';

class CategorySection extends StatefulWidget {
  final String title;
  final TransactionType transactionType;
  final Box<TransactionModel> transactionBox;
  final DateTime selectedMonth;

  const CategorySection({
    super.key,
    required this.title,
    required this.transactionType,
    required this.transactionBox,
    required this.selectedMonth,
  });

  @override
  CategorySectionState createState() => CategorySectionState();
}

class CategorySectionState extends State<CategorySection>
    with CategoryManagementMixin {
  final CategoryHelper _categoryHelper = CategoryHelper();
  late List<Map<String, dynamic>> categories;
  final ColorHelper _colorHelper = ColorHelper();

  @override
  void initState() {
    super.initState();
    _loadAndSortCategories();
  }

  void _loadAndSortCategories() {
    if (widget.transactionType == TransactionType.payment) {
      categories = _categoryHelper.paymentCategories;
    } else {
      categories = _categoryHelper.receiptCategories;
    }

    // categories.sort(
    //     (a, b) => a['name'].toLowerCase().compareT3o(b['name'].toLowerCase()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryTile(
            transactionCount:
                _categoryHelper.getNumberOfTransactionsPerCategory(
              category['name'],
              widget.transactionType,
              widget.transactionBox,
            ),
            categoryData: category,
            transactionBox: widget.transactionBox,
            selectedMonth: widget.selectedMonth,
            title: widget.title,
            onCategoryUpdated: _updateCategory,
            onCategoryDeleted: _deleteCategory,
            color: _colorHelper.darkorWhite(context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _updateCategory(String oldName, Map<String, dynamic> newData) {
    setState(() {
      final index = categories.indexWhere((cat) => cat['name'] == oldName);
      if (index != -1) {
        categories[index] = newData;
        _loadAndSortCategories();
      }
    });
  }

  void _deleteCategory(String categoryName) {
    setState(() {
      categories.removeWhere((category) => category['name'] == categoryName);
    });
  }

  void _showAddCategoryBottomSheet(BuildContext context) {
    String storageKey = widget.transactionType == TransactionType.payment
        ? 'payment_categories'
        : 'receipt_categories';

    showAddCategoryBottomSheet(
      context,
      widget.title,
      storageKey,
    );
  }

  @override
  void onCategoryAdded() {
    _loadAndSortCategories();
  }
}
