import 'package:get/get.dart';
import 'package:to_do_list/features/todo/data/repo/task_repo.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/task_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxList<Task> tasks = <Task>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt sortOption = 0.obs; // 0: Creation date, 1: Due date, 2: Priority

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    tasks.value = await _repository.getTasks();
    _sortTasks();
    _scheduleNotifications();
  }

  void _sortTasks() {
    switch (sortOption.value) {
      case 0: // Creation date
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 1: // Due date
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 2: // Priority
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }
  }

  List<Task> get filteredTasks {
    if (searchQuery.isEmpty) {
      return tasks;
    }

    return tasks.where((task) {
      return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> addTask(
      String title, String description, DateTime dueDate, int priority) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
    );

    await _repository.addTask(task);
    await _loadTasks();
    _scheduleNotification(task);
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await _loadTasks();
    _scheduleNotification(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await _loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSortOption(int option) {
    sortOption.value = option;
    _sortTasks();
  }

  Future<void> _scheduleNotifications() async {
    await _notificationsPlugin.cancelAll();
    for (final task in tasks) {
      if (!task.isCompleted) {
        _scheduleNotification(task);
      }
    }
  }

  Future<void> _initNotifications() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.isCompleted || task.dueDate.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final scheduledDate = task.dueDate.subtract(const Duration(hours: 1));

    if (scheduledDate.isAfter(DateTime.now())) {
      final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        'Task Due Soon: ${task.title}',
        'Your task is due in 1 hour',
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

