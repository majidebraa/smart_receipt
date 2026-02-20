import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../expense_controller.dart';
import '../model/expense.dart';
import 'dart:io';

import 'dart:convert';

import '../notification_service.dart';
import 'full_screen_image_page.dart';
import '../theme/app_theme.dart';


class AddExpensePage extends StatefulWidget {
  final ExpenseModel? editExpense;

  const AddExpensePage({super.key, this.editExpense});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final ExpenseController controller = Get.find();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String selectedCategory = "Grocery";
  DateTime selectedDate = DateTime.now();
  String? imageBase64;

  final ImagePicker picker = ImagePicker();

  final List<String> categories = [
    "Grocery",
    "Taxi",
    "Restaurant",
    "Shopping",
    "Bills",
    "Other"
  ];

  bool enableReminder = false;
  String selectedReminderType = "Electricity";
  DateTime? reminderDate;
  TimeOfDay? reminderTime;

  final List<String> reminderTypes = [
    "Electricity",
    "Water",
    "Gas",
    "Phone Bill",
    "Internet",
    "Debt",
    "Loan Payment",
    "Rent",
    "Check Payment",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.editExpense != null) {
      final e = widget.editExpense!;
      amountController.text = e.amount.toString();
      noteController.text = e.note;
      selectedCategory = e.category;
      selectedDate = e.date;
      imageBase64 = e.imageBase64;

      enableReminder = e.hasReminder;
      selectedReminderType = e.reminderType ?? selectedReminderType;
      reminderDate = e.reminderDate;
      reminderTime = e.reminderTime;
    }
  }

  Future<void> pickCamera() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() => imageBase64 = base64Encode(bytes));
    }
  }

  Future<void> pickGallery() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() => imageBase64 = base64Encode(bytes));
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: selectedDate,
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickReminderDate() async {
    final DateTime? d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (d != null) {
      setState(() => reminderDate = d);
    }
  }

  Future<void> pickReminderTime() async {
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (t != null) {
      setState(() => reminderTime = t);
    }
  }

  void saveExpense() async {
    if (amountController.text.trim().isEmpty) {
      Get.snackbar("Error", "Amount cannot be empty",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // If reminder enabled → category MUST be Bills
    if (enableReminder) {
      selectedCategory = "Bills";
    }

    // Combine reminder date + time
    DateTime? fullReminderDateTime;
    if (enableReminder && reminderDate != null && reminderTime != null) {
      fullReminderDateTime = DateTime(
        reminderDate!.year,
        reminderDate!.month,
        reminderDate!.day,
        reminderTime!.hour,
        reminderTime!.minute,
      );

      // Prevent scheduling past reminders
      if (fullReminderDateTime.isBefore(DateTime.now())) {
        Get.snackbar("Invalid Time", "Reminder time cannot be in the past.",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
    }

    // ================================
    //     EDIT EXPENSE MODE
    // ================================
    if (widget.editExpense != null) {

      final oldExpense = widget.editExpense!;

      final updated = ExpenseModel(
        id: oldExpense.id,
        title: '',
        category: selectedCategory,
        amount: double.parse(amountController.text),
        date: selectedDate,
        note: noteController.text,
        imageBase64: imageBase64,
        reminderType: enableReminder ? selectedReminderType : null,
        reminderDate: enableReminder ? fullReminderDateTime : null,
        reminderTime: enableReminder ? reminderTime : null,
        hasReminder: enableReminder,
      );

      controller.updateExpense(updated);

      // 🔔 CANCEL old reminder first
      if (oldExpense.hasReminder) {
        await NotificationService.cancelReminder(oldExpense.id);
      }

      // 🔔 Schedule NEW reminder if enabled
      if (enableReminder && fullReminderDateTime != null) {
        await NotificationService.scheduleReminder(
          id: updated.id,
          title: "Bill Reminder",
          dateTime: fullReminderDateTime,
        );
      }

      Get.back();
      return;
    }

    // ================================
    //        ADD EXPENSE MODE
    // ================================
    final newItem = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      category: selectedCategory,
      amount: double.parse(amountController.text),
      date: selectedDate,
      note: noteController.text,
      imageBase64: imageBase64,
      reminderType: enableReminder ? selectedReminderType : null,
      reminderDate: enableReminder ? fullReminderDateTime : null,
      reminderTime: enableReminder ? reminderTime : null,
      hasReminder: enableReminder,
    );

    controller.addExpense(newItem);

    // 🔔 Schedule reminder for new item
    if (enableReminder && fullReminderDateTime != null) {
      await NotificationService.scheduleReminder(
        id: newItem.id,
        title: "Bill Reminder",
        dateTime: fullReminderDateTime,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editExpense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Expense" : "Add Expense"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
        
              // CAMERA & GALLERY
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickCamera,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: _boxDecoration(),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: AppTheme.primary),
                            SizedBox(height: 8),
                            Text("Take Photo")
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: pickGallery,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: _boxDecoration(),
                        child: Column(
                          children: [
                            Icon(Icons.image, size: 40, color: AppTheme.primary),
                            SizedBox(height: 8),
                            Text("Pick from Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        
              if (imageBase64 != null) ...[
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Get.to(() => FullScreenImagePage(imageBase64: imageBase64!));
                  },
                  child: Hero(
                    tag: imageBase64!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(imageBase64!),
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              ],
        
              SizedBox(height: 20),
        
              // Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
              ),
        
              SizedBox(height: 16),
        
              // Category
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: _boxDecorationWhite(),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  underline: SizedBox(),
                  isExpanded: true,
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: enableReminder
                      ? null // Disabled when reminder ON
                      : (value) => setState(() => selectedCategory = value!),
                ),
              ),
        
              SizedBox(height: 16),
        
              // Date Picker
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: _boxDecorationWhite(),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: AppTheme.primary),
                      SizedBox(width: 12),
                      Text("${selectedDate.toLocal()}".split(" ")[0]),
                    ],
                  ),
                ),
              ),
        
              SizedBox(height: 16),
        
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Note"),
              ),
        
              SizedBox(height: 16),
        
              // Reminder Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: _boxDecorationWhite(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add Reminder",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Switch(
                          value: enableReminder,
                          onChanged: (v) {
                            setState(() {
                              enableReminder = v;
                              if (v == true) selectedCategory = "Bills";
                            });
                          },
                        ),
                      ],
                    ),
        
                    if (enableReminder) ...[
                      SizedBox(height: 12),
                      DropdownButton<String>(
                        value: selectedReminderType,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: reminderTypes.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedReminderType = v!),
                      ),
        
                      SizedBox(height: 12),
        
                      // Reminder DATE
                      GestureDetector(
                        onTap: pickReminderDate,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: _boxDecorationWhite(),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: AppTheme.primary),
                              SizedBox(width: 12),
                              Text(reminderDate == null
                                  ? "Select reminder date"
                                  : reminderDate!.toString().split(" ")[0]),
                            ],
                          ),
                        ),
                      ),
        
                      SizedBox(height: 12),
        
                      // Reminder TIME
                      GestureDetector(
                        onTap: pickReminderTime,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: _boxDecorationWhite(),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: AppTheme.primary),
                              SizedBox(width: 12),
                              Text(reminderTime == null
                                  ? "Select reminder time"
                                  : "${reminderTime!.hour}:${reminderTime!.minute.toString().padLeft(2, '0')}"),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
        
              SizedBox(height: 24),
        
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveExpense,
                  child: Text(isEditing ? "Update Expense" : "Save Expense"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );

  BoxDecoration _boxDecorationWhite() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade300),
  );
}

