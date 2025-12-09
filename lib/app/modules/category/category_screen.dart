import 'package:yarima_wallet_pro/app/models/transaction_model.dart';
import 'package:yarima_wallet_pro/app/modules/category/components/category_section.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onCategoryAdded;
  final DateTime selectDate;

  const CategoryScreen({
    this.onCategoryAdded,
    super.key,
    required this.selectDate,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Box<TransactionModel> transactionBox =
      Hive.box<TransactionModel>('transactions');
  DateTime selectedMonth = DateTime.now();
  TextEditingController searchController = TextEditingController();

  void _navigateToCategorySection(Widget section) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => section));
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;
    final bool isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
            vertical: 16.0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isTablet && isLandscape) {
                // Tablet landscape layout - grid with 2 rows and 2 columns
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: _buildCategoryCards(),
                );
              } else if (isTablet || isLandscape) {
                // Tablet portrait or phone landscape - grid with 2 columns
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: _buildCategoryCards(),
                );
              } else {
                // Phone portrait - single column list
                return ListView.separated(
                  itemCount: 2,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16.0),
                  itemBuilder: (context, index) => _buildCategoryCards()[index],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryCards() {
    return [
      _buildCategoryCard(
        title: 'Income Categories',
        image: 'assets/categories/receipt.png',
        onTap: () => _navigateToCategorySection(
          CategorySection(
            title: 'Income Categories',
            transactionType: TransactionType.receipt,
            transactionBox: transactionBox,
            selectedMonth: selectedMonth,
          ),
        ),
      ),
      _buildCategoryCard(
        title: 'Expense Categories',
        image: 'assets/categories/payment.png',
        onTap: () => _navigateToCategorySection(
          CategorySection(
            title: 'Expense Categories',
            transactionType: TransactionType.payment,
            transactionBox: transactionBox,
            selectedMonth: selectedMonth,
          ),
        ),
      ),
    ];
  }

  Widget _buildCategoryCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double imageSize = cardWidth * 0.1; // Responsive image size

        return GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardWidth * 0.04),
              child: Row(
                spacing: cardWidth * 0.045,
                children: [
                  Image.asset(
                    image,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: cardWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: imageSize * 0.8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
