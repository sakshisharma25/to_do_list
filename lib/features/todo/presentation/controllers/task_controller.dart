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
      case 0:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 1:
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 2:
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
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.isCompleted) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final now = DateTime.now();
    if (task.dueDate.isAfter(now)) {
      try {
        final int delayMs = task.dueDate.difference(now).inMilliseconds;
        final int notificationId = task.id.hashCode.abs() % 100000;

        print('Task "${task.title}" due at ${task.dueDate}');
        print('Current time: $now');
        print('Scheduling notification with delay of ${delayMs}ms');

        Future.delayed(Duration(milliseconds: delayMs), () async {
          final currentTasks = await _repository.getTasks();
          final taskStillExists =
              currentTasks.any((t) => t.id == task.id && !t.isCompleted);

          if (taskStillExists) {
            await _notificationsPlugin.show(
              notificationId,
              'Task Due Now: ${task.title}',
              'Your task "${task.title}" is due now',
              notificationDetails,
            );

            print('Showed due time notification for task "${task.title}"');
          }
        });

        print('Scheduled due time notification for task "${task.title}"');

        final List<int> reminderMinutes = [];
        reminderMinutes.add(15);
        if (task.priority >= 2) {
          reminderMinutes.add(60);
        }
        if (task.priority == 3) {
          reminderMinutes.add(24 * 60);
        }
        for (final minutes in reminderMinutes) {
          final reminderDelayMs = delayMs - (minutes * 60 * 1000);
          if (reminderDelayMs > 0) {
            Future.delayed(Duration(milliseconds: reminderDelayMs), () async {
              final currentTasks = await _repository.getTasks();
              final taskStillExists =
                  currentTasks.any((t) => t.id == task.id && !t.isCompleted);

              if (taskStillExists) {
                String timeText;
                if (minutes < 60) {
                  timeText = '$minutes minutes';
                } else if (minutes == 60) {
                  timeText = '1 hour';
                } else if (minutes == 24 * 60) {
                  timeText = '1 day';
                } else {
                  timeText = '${minutes / 60} hours';
                }

                await _notificationsPlugin.show(
                  notificationId + reminderMinutes.indexOf(minutes) + 1,
                  'Task Due Soon: ${task.title}',
                  'Your task "${task.title}" is due in $timeText',
                  notificationDetails,
                );

                print('Showed $timeText reminder for task "${task.title}"');
              }
            });

            print(
                'Scheduled ${minutes}-minute reminder for task "${task.title}"');
          }
        }
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }
  }

  Future<void> testNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notificationsPlugin.show(
        9999,
        'Immediate Test Notification',
        'This notification should appear immediately',
        notificationDetails,
      );
      print('Immediate notification sent');
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = now.add(const Duration(seconds: 10));

      print('Current time: $now');
      print('Scheduling test notification for: $scheduledTime');

      await _notificationsPlugin.zonedSchedule(
        9998,
        '10-Second Test Notification',
        'This notification should appear 10 seconds after the test',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Scheduled test notification for 10 seconds later');
      await _checkPendingNotifications();
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  Future<void> _checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();

    print('Pending notifications count: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print(
          'Pending notification - ID: ${notification.id}, Title: ${notification.title}');
    }
  }
}
