import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/expense.dart';

class StorageService {

  static const String key = "expenses";

  // ─────────────────────────────── SAVE ───────────────────────────────
  static Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = expenses.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList(key, jsonList);
  }

  // ─────────────────────────────── LOAD ───────────────────────────────
  static Future<List<ExpenseModel>> loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? stored = prefs.getStringList(key);

    if (stored == null) return [];

    return stored.map((item) {
      return ExpenseModel.fromJson(jsonDecode(item));
    }).toList();
  }
}
