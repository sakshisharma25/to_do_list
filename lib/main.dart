import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/core/theme/app_theme.dart';


void main() {
  runApp(const MyApp());
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
      initialBinding: TaskBinding(),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}