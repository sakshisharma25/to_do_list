import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskController controller = Get.find<TaskController>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late int selectedPriority;
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    selectedDate = widget.task.dueDate;
    selectedPriority = widget.task.priority;
    isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              controller.deleteTask(widget.task.id);
              Get.back();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Due Date: ', style: TextStyle(fontSize: 16)),
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Priority: ', style: TextStyle(fontSize: 16)),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value!;
                    });
                  },
                ),
                const Text('Mark as completed', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Title cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: titleController.text,
      description: descriptionController.text,
      dueDate: selectedDate,
      priority: selectedPriority,
      isCompleted: isCompleted,
    );

    controller.updateTask(updatedTask);
    Get.back();
  }
}