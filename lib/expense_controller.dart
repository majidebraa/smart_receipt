import 'package:get/get.dart';
import 'local/expense_storage.dart';
import 'model/expense.dart';

class ExpenseController extends GetxController {
  RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  void loadData() async {
    expenses.value = await StorageService.loadExpenses();
  }


  void addExpense(ExpenseModel expense) {
    expenses.add(expense);
    save();
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    save();
  }

  void updateExpense(ExpenseModel updated) {
    int index = expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      expenses[index] = updated;
      save();
    }
  }

  Future<void> save() async {
    await StorageService.saveExpenses(expenses.toList());
  }


  double getTotalThisMonth() {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
}
