import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/core/theme/app_theme.dart';
import 'package:to_do_list/features/todo/presentation/controllers/task_controller.dart';
import 'package:to_do_list/features/todo/presentation/screens/todo_home_screen.dart';


void main() {
  runApp(const MyApp());
  Get.put(TaskController());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo List App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}