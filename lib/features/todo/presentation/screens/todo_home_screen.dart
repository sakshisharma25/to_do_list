import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/features/todo/presentation/widgets/task_detail_screen.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_list_item.dart';

class HomeScreen extends StatelessWidget {
  final TaskController controller = Get.find<TaskController>();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setSearchQuery,
            ),
          ),
          Expanded(
            child: Obx(() {
              final tasks = controller.filteredTasks;
              
              if (tasks.isEmpty) {
                return const Center(
                  child: Text('No tasks found. Add a new task!'),
                );
              }
              
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskListItem(
                    task: task,
                    onTap: () => Get.to(() => TaskDetailScreen(task: task)),
                    onToggle: () => controller.toggleTaskCompletion(task),
                    onDelete: () => controller.deleteTask(task.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Creation Date'),
                onTap: () {
                  controller.setSortOption(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Due Date'),
                onTap: () {
                  controller.setSortOption(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.priority_high),
                title: const Text('Priority'),
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
    int selectedPriority = 2; // Medium priority by default

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Due Date: '),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Priority: '),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: selectedPriority,
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Low'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('High'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
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
                    if (titleController.text.isNotEmpty) {
                      controller.addTask(
                        titleController.text,
                        descriptionController.text,
                        selectedDate,
                        selectedPriority,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}