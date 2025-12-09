import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:yarima_wallet_pro/app/data/helpers/color_helper.dart';
import 'package:yarima_wallet_pro/app/models/task_model.dart';
import 'package:yarima_wallet_pro/app/modules/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final titleController = TextEditingController();
  final descpController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<TaskModel> tasks = [];
  Map<DateTime, List<TaskModel>> allTasks = {};
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
  }

  void _loadAllTasks() async {
    final box = await Hive.openBox<TaskModel>('tasks');
    final allTasksList = box.values.toList();

    setState(() {
      allTasks = {};
      for (var task in allTasksList) {
        final date = DateTime(
            task.startTime.year, task.startTime.month, task.startTime.day);
        if (!allTasks.containsKey(date)) {
          allTasks[date] = [];
        }
        allTasks[date]!.add(task);
      }
      _loadTasksForSelectedDate();
    });
  }

  void _loadTasksForSelectedDate() {
    final date =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    setState(() {
      tasks = allTasks[date] ?? [];
    });
  }

  Future<void> _saveTask(TaskModel task) async {
    final box = await Hive.openBox<TaskModel>('tasks');
    await box.add(task);
    _loadAllTasks();
  }

  Future<void> _updateTask(TaskModel task) async {
    await task.save();
    _loadAllTasks();
  }

  Future<void> _deleteTask(TaskModel task) async {
    await task.delete();
    _loadAllTasks();
  }

  void _showAddEditTaskDialog({TaskModel? task}) {
    final isEditing = task != null;
    if (isEditing) {
      titleController.text = task.eventTitle;
      descpController.text = task.eventDescp;
      selectedStartTime = TimeOfDay.fromDateTime(task.startTime);
      selectedEndTime = TimeOfDay.fromDateTime(task.endTime);
    } else {
      titleController.clear();
      descpController.clear();
      selectedStartTime = null;
      selectedEndTime = null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descpController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => selectedStartTime = time);
                          }
                        },
                        child: Text(selectedStartTime != null
                            ? selectedStartTime!.format(context)
                            : 'Start Time'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => selectedEndTime = time);
                          }
                        },
                        child: Text(selectedEndTime != null
                            ? selectedEndTime!.format(context)
                            : 'End Time'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    descpController.text.isEmpty ||
                    selectedStartTime == null ||
                    selectedEndTime == null) {
                  const CustomToast(message: 'Please fill all fields')
                      .showToast(context);
                  return;
                }
                final newTask = TaskModel(
                  eventTitle: titleController.text,
                  eventDescp: descpController.text,
                  startTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedStartTime!.hour,
                    selectedStartTime!.minute,
                  ),
                  endTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedEndTime!.hour,
                    selectedEndTime!.minute,
                  ),
                );
                if (isEditing) {
                  task.eventTitle = newTask.eventTitle;
                  task.eventDescp = newTask.eventDescp;
                  task.startTime = newTask.startTime;
                  task.endTime = newTask.endTime;
                  _updateTask(task);
                } else {
                  _saveTask(newTask);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  });
                  _loadTasksForSelectedDate();
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  });
                  _loadTasksForSelectedDate();
                },
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final date = DateTime(selectedDate.year, selectedDate.month, 1)
                    .subtract(Duration(
                        days: DateTime(selectedDate.year, selectedDate.month, 1)
                                .weekday -
                            1))
                    .add(Duration(days: index));
                final isCurrentMonth = date.month == selectedDate.month;
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final tasksForDate =
                    allTasks[DateTime(date.year, date.month, date.day)] ?? [];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    _loadTasksForSelectedDate();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      color: isSelected ? Colors.blue[100] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isCurrentMonth
                                ? ColorHelper().darkorWhite(context)
                                : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isCurrentMonth)
                          ...List.generate(
                            tasksForDate.length.clamp(0, 4),
                            (index) => Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .primaries[index % Colors.primaries.length],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final color = Colors.primaries[index % Colors.primaries.length];
          return Dismissible(
            key: Key(task.hashCode.toString()),
            background: Container(
              color: AppColor.kPrimary,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteTask(task);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(task.eventTitle,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${DateFormat('hh:mm a').format(task.startTime)} - ${DateFormat('hh:mm a').format(task.endTime)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => _showAddEditTaskDialog(task: task),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do')),
      body: Column(
        children: [
          _buildCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: Row(
              children: [
                Text(
                  DateFormat('EEE').format(selectedDate),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d').format(selectedDate),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
          ),
          _buildTaskList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
