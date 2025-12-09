import 'package:yarima_wallet_pro/app/data/helpers/icon_helper.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/category/category_screen.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_outline_button.dart';
import 'package:yarima_wallet_pro/app/modules/category/components/category_helper.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategorySelection extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final TransactionType transactionType;
  final Function(String, String?) onCategorySelected;
  final Function(String, String) onCategoryCreated;
  final VoidCallback? onCategoryAdded;
  final Box<TransactionModel> transactionBox;
  final String? previouslySelectedCategory;
  final DateTime selectedDailyDate;

  const CategorySelection({
    super.key,
    required this.categories,
    required this.transactionType,
    required this.onCategorySelected,
    this.onCategoryAdded,
    this.previouslySelectedCategory,
    required this.selectedDailyDate,
    required this.onCategoryCreated,
    required this.transactionBox,
  });

  @override
  CategorySelectionState createState() => CategorySelectionState();
}

class CategorySelectionState extends State<CategorySelection> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> filteredCategories = [];
  List<Map<String, dynamic>> customCategories = [];

  String? expandedCategory;
  String? lastSelectedCategory;
  ScrollController scrollController = ScrollController();
  final CategoryHelper categoryHelper = CategoryHelper();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadLastSelectedCategory();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(allCategories);
      } else {
        // Filter regular categories
        filteredCategories = allCategories.where((category) {
          final categoryNameMatches =
              category['name'].toString().toLowerCase().contains(query);

          return categoryNameMatches;
        }).toList();

        // Filter general categories
      }
      _sortCategories(filteredCategories);
    });
  }

  void _loadCategories() {
    final receiptBox = GetStorage('receipt_categories');
    final paymentBox = GetStorage('payment_categories');
    final receiptKeys = receiptBox.getKeys()?.cast<String>() ?? [];
    final paymentKeys = paymentBox.getKeys()?.cast<String>() ?? [];

    // Load categories based on transaction type
    if (widget.transactionType == TransactionType.receipt) {
      allCategories = [
        ...customCategories,
        ..._convertKeysToCategoryList(receiptKeys, receiptBox),
        ...categoryHelper.receiptCategories
            .map((c) => _mergeWithStoredData(c, receiptBox)),
      ];
    } else {
      allCategories = [
        ...customCategories,
        ..._convertKeysToCategoryList(paymentKeys, paymentBox),
        ...categoryHelper.paymentCategories
            .map((c) => _mergeWithStoredData(c, paymentBox)),
      ];
    }

    // Remove duplicates
    allCategories =
        allCategories.fold<List<Map<String, dynamic>>>([], (prev, element) {
      if (!prev.any((e) => e['name'] == element['name'])) {
        prev.add(element);
      }
      return prev;
    });

    setState(() {
      filteredCategories = List.from(allCategories);

      _sortCategories(filteredCategories);
    });
  }

  Map<String, dynamic> _mergeWithStoredData(
      Map<String, dynamic> defaultCategory, GetStorage box) {
    final storedData =
        box.read(defaultCategory['name']) as Map<dynamic, dynamic>?;
    if (storedData != null) {
      return {
        ...defaultCategory,
        ...storedData,
        'isDefault': true,
      };
    }
    return {...defaultCategory, 'isDefault': true};
  }

  List<Map<String, dynamic>> _convertKeysToCategoryList(
      Iterable<String> keys, GetStorage box) {
    return keys.map((key) {
      final categoryData = box.read(key) as Map<dynamic, dynamic>?;
      String imagePath = categoryData?['imagePath'] ??
          CustomIcons().getImagePathForCategory(key);

      return {
        'name': key,
        'imagePath': imagePath,
      };
    }).toList();
  }

  void _sortCategories(List<Map<String, dynamic>> categories) {
    categories.sort((a, b) {
      if (a['name'] == lastSelectedCategory) return -1;
      if (b['name'] == lastSelectedCategory) return 1;
      return a['name'].toString().compareTo(b['name'].toString());
    });
  }

  Future<void> _loadLastSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastSelectedCategory = prefs.getString('lastSelectedCategory');
      _sortCategories(filteredCategories);
    });
  }

  Future<void> _saveLastSelectedCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedCategory', category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search categories',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: filteredCategories.length + 1,
              itemBuilder: (context, index) {
                if (index < filteredCategories.length) {
                  return _buildCategoryTile(filteredCategories[index]);
                } else {
                  return null;
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomOutlineButton(
              onTap: () => _navigateToCategorySection(context),
              text: 'Add Categories',
              categoryPath: Icons.add,
              height: 46,
              width: 150,
              borderRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    return ListTile(
      leading: Image.asset(
        category['imagePath'],
        height: 30,
        width: 30,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return const Icon(Icons.error);
        },
      ),
      title: Text(category['name'].toString()),
      onTap: () =>
          _selectCategory(category['name'].toString(), category['imagePath']),
    );
  }

  void _selectCategory(String categoryName, String imagePath) {
    widget.onCategorySelected(
      categoryName,
      imagePath,
    );

    _saveLastSelectedCategory(categoryName);
    Navigator.pop(context);
  }

  void _navigateToCategorySection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          selectDate: widget.selectedDailyDate,
          onCategoryAdded: _onCategoryAdded,
        ),
      ),
    );
  }

  void _onCategoryAdded() {
    _loadCategories();
    widget.onCategoryAdded?.call();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
