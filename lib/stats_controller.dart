import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'local/expense_storage.dart';
import 'model/expense.dart';

class StatsController extends GetxController {
  RxList<ExpenseModel> allExpenses = <ExpenseModel>[].obs;

  RxDouble total = 0.0.obs;
  RxMap<String, double> categoryTotals = <String, double>{}.obs;

  RxString selectedTab = "Monthly".obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    allExpenses.value = await StorageService.loadExpenses();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    filterExpenses();
  }

  void filterExpenses() {
    DateTime now = DateTime.now();
    List<ExpenseModel> filtered = [];

    if (selectedTab.value == "Daily") {
      filtered = allExpenses.where((e) =>
      DateFormat("yyyy-MM-dd").format(e.date) ==
          DateFormat("yyyy-MM-dd").format(now)
      ).toList();
    }

    else if (selectedTab.value == "Weekly") {
      DateTime weekAgo = now.subtract(Duration(days: 7));
      filtered = allExpenses.where((e) => e.date.isAfter(weekAgo)).toList();
    }

    else {
      filtered = allExpenses.where((e) =>
      e.date.year == now.year && e.date.month == now.month
      ).toList();
    }

    calcTotals(filtered);
  }

  void calcTotals(List<ExpenseModel> list) {
    total.value = list.fold(0, (sum, item) => sum + item.amount);

    categoryTotals.clear();

    for (var item in list) {
      categoryTotals[item.category] =
          (categoryTotals[item.category] ?? 0) + item.amount;
    }

    categoryTotals.refresh();
  }
}
