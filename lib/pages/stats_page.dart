import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../expense_controller.dart';
import 'package:fl_chart/fl_chart.dart';


class StatsPage extends StatelessWidget {
  final ExpenseController controller = Get.find();

  StatsPage({super.key});

  // Colors for categories
  final List<Color> categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.cyan,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final expenses = controller.expenses;
          if (expenses.isEmpty) {
            return Center(
              child: Text("No expenses yet", style: TextStyle(fontSize: 18)),
            );
          }

          // Group expenses by category
          final Map<String, double> categoryTotals = {};
          for (var e in expenses) {
            if (categoryTotals.containsKey(e.category)) {
              categoryTotals[e.category] = categoryTotals[e.category]! + e.amount;
            } else {
              categoryTotals[e.category] = e.amount;
            }
          }

          final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

          // Pie chart sections
          final sections = categoryTotals.entries.map((entry) {
            final index = categoryTotals.keys.toList().indexOf(entry.key);
            return PieChartSectionData(
              color: categoryColors[index % categoryColors.length],
              value: entry.value,
              title:
              "${((entry.value / total) * 100).toStringAsFixed(1)}%",
              radius: 80,
              titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            );
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Expenses: \$${total.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Pie chart
              Center(
                child: SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Legend
              Expanded(
                child: ListView(
                  children: categoryTotals.entries.map((entry) {
                    final index =
                    categoryTotals.keys.toList().indexOf(entry.key);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        categoryColors[index % categoryColors.length],
                        radius: 10,
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                          "\$${entry.value.toStringAsFixed(2)} (${((entry.value / total) * 100).toStringAsFixed(1)}%)"),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}


