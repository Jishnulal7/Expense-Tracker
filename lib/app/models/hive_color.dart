import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'hive_color.g.dart';

@HiveType(typeId: 20)
class HiveColor {
  @HiveField(0, defaultValue: 0)
  final int value;

  HiveColor(this.value);

  Color toColor() => Color(value);
  static HiveColor fromColor(Color color) => HiveColor(color.value);
}