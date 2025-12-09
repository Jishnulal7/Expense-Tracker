import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 9)
class BudgetModel extends HiveObject {
  @HiveField(0,defaultValue: '')
  String id;

  @HiveField(1,defaultValue: '')
  String category;

  @HiveField(2,defaultValue: '')
  double plannedAmount;

  @HiveField(3,defaultValue: '')
  double actualAmount;

  @HiveField(4,defaultValue: '')
  DateTime startDate;

  @HiveField(5,defaultValue: '')
  DateTime endDate;

  @HiveField(6,defaultValue: '')
  BudgetPeriod period;

  @HiveField(7,defaultValue: '')
  String? subCategory;

  BudgetModel({
    String? id,
    required this.category,
    required this.plannedAmount,
    this.actualAmount = 0.0,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.subCategory,
  }) : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 10)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  yearly
}
