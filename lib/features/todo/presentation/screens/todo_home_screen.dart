import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/core/assets/images/image_assets.dart';
import 'package:to_do_list/features/todo/presentation/widgets/task_detail_screen.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_list_item.dart';
import '../../data/models/task_model.dart';

enum TaskFilter { all, today, upcoming, completed }

class HomeScreen extends StatelessWidget {
  final TaskController controller = Get.find<TaskController>();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade200],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              ImageAssets.logo,
                              width: 28,
                              height: 28,
                              color: Colors
                                  .white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Task Master',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.sort, color: Colors.white),
                          onPressed: () => _showSortOptions(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      isScrollable: false, // Change from true to false
                      tabs: [
                        _buildTab('All', null),
                        _buildTab('Today', null),
                        _buildTab('Upcoming', null),
                        _buildTab('Completed', null),
                      ],
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      dividerColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search tasks',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                onChanged: controller.setSearchQuery,
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTaskList(TaskFilter.all, context),
                  _buildTaskList(TaskFilter.today, context),
                  _buildTaskList(TaskFilter.upcoming, context),
                  _buildTaskList(TaskFilter.completed, context),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTab(String text, int? count) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            if (count != null) ...[
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskFilter filter, BuildContext context) {
    return Obx(() {
      final tasks = _getFilteredTasks(filter);

      if (tasks.isEmpty) {
        return _buildEmptyState(filter, context);
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ListView.builder(
          itemCount: tasks.length,
          padding: const EdgeInsets.only(bottom: 80),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListItem(
              task: task,
              onTap: () => Get.to(() => TaskDetailScreen(task: task)),
              onToggle: () => controller.toggleTaskCompletion(task),
              onDelete: () => controller.deleteTask(task.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(TaskFilter filter, BuildContext context) {
    IconData icon;
    String message;

    switch (filter) {
      case TaskFilter.today:
        icon = Icons.today;
        message = 'No tasks for today';
        break;
      case TaskFilter.upcoming:
        icon = Icons.calendar_month;
        message = 'No upcoming tasks';
        break;
      case TaskFilter.completed:
        icon = Icons.task_alt;
        message = 'No completed tasks yet';
        break;
      default:
        icon = Icons.checklist;
        message = 'No tasks found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (filter != TaskFilter.completed)
            ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add a new task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Task> _getFilteredTasks(TaskFilter filter) {
    final allTasks = controller.filteredTasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case TaskFilter.today:
        return allTasks.where((task) {
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
        }).toList();
      case TaskFilter.upcoming:
        return allTasks.where((task) {
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate.isAfter(today) && !task.isCompleted;
        }).toList();
      case TaskFilter.completed:
        return allTasks.where((task) => task.isCompleted).toList();
      default:
        return allTasks;
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text('Creation Date'),
                trailing: Obx(() => controller.sortOption.value == 0
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox.shrink()),
                onTap: () {
                  controller.setSortOption(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: Colors.green),
                title: const Text('Due Date'),
                trailing: Obx(() => controller.sortOption.value == 1
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox.shrink()),
                onTap: () {
                  controller.setSortOption(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.priority_high, color: Colors.green),
                title: const Text('Priority'),
                trailing: Obx(() => controller.sortOption.value == 2
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox.shrink()),
                onTap: () {
                  controller.setSortOption(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedPriority = 2;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_task, color: Colors.green),
                  const SizedBox(width: 12),
                  const Text('Add New Task'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.title, color: Colors.green),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            Icon(Icons.description, color: Colors.green),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Due Date & Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.green,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 18, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.green,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                  selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time,
                                      size: 18, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedTime.format(context),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedPriority = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: selectedPriority == 1
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedPriority == 1
                                    ? Colors.green
                                    : Colors.grey,
                                width: selectedPriority == 1 ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              'Low',
                              style: TextStyle(
                                color: selectedPriority == 1
                                    ? Colors.green
                                    : Colors.grey[600],
                                fontWeight: selectedPriority == 1
                                    ? FontWeight.bold
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedPriority = 2;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: selectedPriority == 2
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedPriority == 2
                                    ? Colors.orange
                                    : Colors.grey,
                                width: selectedPriority == 2 ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              'Medium',
                              style: TextStyle(
                                color: selectedPriority == 2
                                    ? Colors.orange
                                    : Colors.grey[600],
                                fontWeight: selectedPriority == 2
                                    ? FontWeight.bold
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedPriority = 3;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: selectedPriority == 3
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedPriority == 3
                                    ? Colors.red
                                    : Colors.grey,
                                width: selectedPriority == 3 ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              'High',
                              style: TextStyle(
                                color: selectedPriority == 3
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontWeight: selectedPriority == 3
                                    ? FontWeight.bold
                                    : null,
                              ),
                            ),
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
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final combinedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      controller.addTask(
                        titleController.text,
                        descriptionController.text,
                        combinedDateTime,
                        selectedPriority,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
