import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_receipt/theme/app_theme.dart';
import 'expense_controller.dart';
import 'notification_service.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService.init();

  Get.put(ExpenseController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Receipt',
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}

