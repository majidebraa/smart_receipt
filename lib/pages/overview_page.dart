import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../expense_controller.dart';
import '../theme/app_theme.dart';
import 'add_expense_page.dart';


class OverviewPage extends StatelessWidget {
  final ExpenseController controller = Get.find<ExpenseController>();

  final Map<String, IconData> categoryIcons = {
    "Grocery": Icons.shopping_cart,
    "Taxi": Icons.local_taxi,
    "Restaurant": Icons.restaurant,
    "Shopping": Icons.store,
    "Bills": Icons.receipt_long,
    "Other": Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              Expanded(child: _buildExpenseList()),
            ],
          ),
        ),
      ),
    );
  }

  // TOP MONTHLY TOTAL CARD
  Widget _buildHeaderCard() {
    return Obx(() {
      double total = controller.getTotalThisMonth();

      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total this month",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              "${total.toStringAsFixed(0)} \$",
              style: const TextStyle(
                  fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "+17% compared to last month",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    });
  }

  // EXPENSE LIST
  Widget _buildExpenseList() {
    return Obx(() {
      if (controller.expenses.isEmpty) {
        return const Center(
          child: Text("No expenses added yet",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        );
      }

      return ListView.builder(
        itemCount: controller.expenses.length,
        itemBuilder: (context, index) {
          final item = controller.expenses[index];
          final icon = categoryIcons[item.category] ?? Icons.more_horiz;

          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => controller.deleteExpense(item.id),

            child: GestureDetector(
              onTap: () => Get.to(() => AddExpensePage(editExpense: item)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.background,
                      child: Icon(icon, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CATEGORY + REMINDER ICON
                          Row(
                            children: [
                              Text(item.category,
                                  style: TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.bold)),
                              if (item.hasReminder) ...[
                                SizedBox(width: 6),
                                Icon(Icons.alarm,
                                    color: Colors.redAccent, size: 18),
                              ],
                            ],
                          ),

                          // REMINDER DATE + TIME
                          if (item.hasReminder)
                            Text(
                              _formatReminder(item),
                              style: TextStyle(fontSize: 13, color: Colors.red),
                            ),

                          const SizedBox(height: 4),

                          // EXPENSE DATE
                          Text(
                            item.date.toLocal().toString().split(" ")[0],
                            style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "${item.amount.toStringAsFixed(0)} \$",
                      style:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// Format: "Reminder: Electricity — 2025-02-19 at 08:30 AM"
  String _formatReminder(item) {
    final date = item.reminderDate;
    final time = item.reminderTime;

    if (date == null || time == null) return "";

    final dateStr = date.toLocal().toString().split(" ")[0];

    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.period == DayPeriod.am ? "AM" : "PM";

    return "Reminder: ${item.reminderType} — $dateStr at $hour:$minute $ampm";
  }
}
