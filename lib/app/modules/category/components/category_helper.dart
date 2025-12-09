import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:yarima_wallet_pro/app/models/transaction_model.dart';

class CategoryHelper {
  List<Map<String, dynamic>> generalCategories;
  final GetStorage _storage = GetStorage();
  final String _receiptCategoriesKey = 'receipt_categories';
  final String _paymentCategoriesKey = 'payment_categories';

  CategoryHelper() : generalCategories = [] {
    _initializeCategories();
    _initializePaymentCategories();
    _initializeReceiptCategories();
  }

  void _initializeCategories() {
    _initializePaymentCategories();
    _initializeReceiptCategories();
  }

  void _initializePaymentCategories() {
    final storedCategories = _storage.read<List>(_paymentCategoriesKey);
    if (storedCategories == null) {
      final defaultCategories = _getDefaultCategories(_paymentCategoriesKey);
      _storage.write(_paymentCategoriesKey, defaultCategories);
    }
  }

  void _initializeReceiptCategories() {
    final storedCategories = _storage.read<List>(_receiptCategoriesKey);
    if (storedCategories == null) {
      final defaultCategories = _getDefaultCategories(_receiptCategoriesKey);
      _storage.write(_receiptCategoriesKey, defaultCategories);
    }
  }

  List<Map<String, dynamic>> get receiptCategories {
    return _getCategories(_receiptCategoriesKey);
  }

  List<Map<String, dynamic>> get paymentCategories {
    return _getCategories(_paymentCategoriesKey);
  }

  List<Map<String, dynamic>> _getCategories(String key) {
    final storedCategories = _storage.read<List>(key);
    if (storedCategories != null) {
      return storedCategories
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return _getDefaultCategories(key);
  }

  List<Map<String, dynamic>> _getDefaultCategories(String key) {
    if (key == _paymentCategoriesKey) {
      return [
        {
          'name': 'Food',
          'imagePath': 'assets/categories/fast-food.png',
        },
        {
          'name': 'Shopping',
          'imagePath': 'assets/categories/shopping.png',
        },
        {
          'name': 'Transport',
          'imagePath': 'assets/categories/taxi(2).png',
        },
        {
          'name': 'Bills',
          'imagePath': 'assets/categories/bill.png',
        },
        {
          'name': 'Gadgets',
          'imagePath': 'assets/categories/smartphone.png',
        },
        {
          'name': 'Education',
          'imagePath': 'assets/categories/graduation.png',
        },
        {
          'name': 'EMI',
          'imagePath': 'assets/categories/loan.png',
        },
        {
          'name': 'Health',
          'imagePath': 'assets/categories/healthcare-and-medical.png',
        },
        {
          'name': 'Household',
          'imagePath': 'assets/categories/house.png',
        },
        {
          'name': 'Rent',
          'imagePath': 'assets/categories/rent.png',
        },
        {
          'name': 'Invest',
          'imagePath': 'assets/categories/investment.png',
        },
        {
          'name': 'Kids',
          'imagePath': 'assets/categories/feeding-bottle.png',
        },
        {
          'name': 'Leisure',
          'imagePath': 'assets/categories/sports.png',
        },
        {
          'name': 'Office',
          'imagePath': 'assets/categories/briefcase.png',
        },
        {
          'name': 'Travel',
          'imagePath': 'assets/categories/plane.png',
        },
        {
          'name': 'Subscription',
          'imagePath': 'assets/categories/subscription.png',
        },
        {
          'name': 'Entertainment',
          'imagePath': 'assets/categories/tickets.png',
        },
        {
          'name': 'Utilities',
          'imagePath': 'assets/categories/lightning-bolt.png',
        },
      ];
    } else if (key == _receiptCategoriesKey) {
      return [
        {
          'name': 'Bills',
          'imagePath': 'assets/categories/bill.png',
        },
        {
          'name': 'Rent',
          'imagePath': 'assets/categories/rent.png',
        },
        {
          'name': 'Invest',
          'imagePath': 'assets/categories/investment.png',
        },
        {
          'name': 'Office',
          'imagePath': 'assets/categories/briefcase.png',
        },
        {
          'name': 'Salary',
          'imagePath': 'assets/categories/money-bag.png',
        },
        {
          'name': 'Rewards',
          'imagePath': 'assets/categories/gift.png',
        },
        {
          'name': 'Bonus',
          'imagePath': 'assets/categories/gift-card.png',
        },
      ];
    } else if (key == _receiptCategoriesKey) {
      return [
        {
          'name': 'Bills',
          'imagePath': 'assets/categories/bill.png',
        },
        {
          'name': 'Rent',
          'imagePath': 'assets/categories/rent.png',
        },
        {
          'name': 'Invest',
          'imagePath': 'assets/categories/investment.png',
        },
        {
          'name': 'Office',
          'imagePath': 'assets/categories/briefcase.png',
        },
        {
          'name': 'Salary',
          'imagePath': 'assets/categories/money-bag.png',
        },
        {
          'name': 'Rewards',
          'imagePath': 'assets/categories/gift.png',
        },
        {
          'name': 'Bonus',
          'imagePath': 'assets/categories/gift-card.png',
        },
      ];
    }
    return [];
  }

  void addCategory(String name, String imagePath, TransactionType type,
      {List<dynamic>? subcategories}) {
    final newCategory = {
      'name': name,
      'imagePath': imagePath,
    };
    if (type == TransactionType.payment) {
      final categories = paymentCategories;
      categories.add(newCategory);
      _storage.write(_paymentCategoriesKey, categories);
    } else if (type == TransactionType.receipt) {
      final categories = receiptCategories;
      categories.add(newCategory);
      _storage.write(_receiptCategoriesKey, categories);
    }
  }

  void updateCategory(
      String oldName, String newName, String newImagePath, TransactionType type,
      {List<dynamic>? newSubcategories}) {
    if (type == TransactionType.payment) {
      final categories = paymentCategories;
      final index =
          categories.indexWhere((category) => category['name'] == oldName);
      if (index != -1) {
        categories[index] = {
          'name': newName,
          'imagePath': newImagePath,
        };
        _storage.write(_paymentCategoriesKey, categories);
      }
    } else if (type == TransactionType.receipt) {
      final categories = receiptCategories;
      final index =
          categories.indexWhere((category) => category['name'] == oldName);
      if (index != -1) {
        categories[index] = {
          'name': newName,
          'imagePath': newImagePath,
        };
        _storage.write(_receiptCategoriesKey, categories);
      }
    }
  }

  void deleteCategory(String name, TransactionType type) {
    if (type == TransactionType.payment) {
      final categories = paymentCategories;
      categories.removeWhere((category) => category['name'] == name);
      _storage.write(_paymentCategoriesKey, categories);
    } else if (type == TransactionType.receipt) {
      final categories = receiptCategories;
      categories.removeWhere((category) => category['name'] == name);
      _storage.write(_receiptCategoriesKey, categories);
    }
  }

  // New methods for managing subcategories

  void deleteSubcategory(
      String categoryName, String subcategoryName, TransactionType type) {
    final categories = (type == TransactionType.payment)
        ? paymentCategories
        : receiptCategories;
    final categoryIndex =
        categories.indexWhere((category) => category['name'] == categoryName);

    if (categoryIndex != -1 &&
        categories[categoryIndex].containsKey('subcategories')) {
      final subcategories = categories[categoryIndex]['subcategories'] as List;
      subcategories.remove(subcategoryName);

      final storageKey = (type == TransactionType.payment)
          ? _paymentCategoriesKey
          : _receiptCategoriesKey;
      _storage.write(storageKey, categories);
    }
  }

  List<TransactionModel> getCategoryFromTransactions(
    DateTime selectedMonth,
    Box<TransactionModel> transactionBox,
    List<TransactionType> types,
    String category,
  ) {
    try {
      return transactionBox.values
          .where((transaction) =>
              types.contains(transaction.transactionType) &&
              transaction.categoryName == category)
          .toList();
    } catch (e) {
      debugPrint('Error getting category from transactions: $e');
      return [];
    }
  }

  int getNumberOfTransactionsPerCategory(
    String categoryName,
    TransactionType transactionType,
    Box<TransactionModel> transactionBox,
  ) {
    try {
      return transactionBox.values
          .where((transaction) =>
              transaction.categoryName == categoryName &&
              transaction.transactionType == transactionType)
          .length;
    } catch (e) {
      debugPrint('Error getting number of transactions: $e');
      return 0;
    }
  }

  final allTransactionTypes = [
    TransactionType.payment,
    TransactionType.receipt,
  ];
}
