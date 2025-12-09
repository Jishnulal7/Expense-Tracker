import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 6)
class TaskModel extends HiveObject {
  @HiveField(0)
  String eventTitle;

  @HiveField(1)
  String eventDescp;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  
  TaskModel({
    required this.eventTitle,
    required this.eventDescp,
    required this.startTime,
    required this.endTime,
  });
}
