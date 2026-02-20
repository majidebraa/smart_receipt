import 'package:flutter/material.dart';

class ExpenseModel {
  String id;
  String title;
  double amount;
  String category;
  DateTime date;
  String note;

  // IMAGE (Base64)
  String? imageBase64;

  // REMINDER FIELDS
  String? reminderType;
  DateTime? reminderDate; // full date+time combined
  TimeOfDay? reminderTime; // stored separately
  bool hasReminder;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,

    this.imageBase64,

    this.reminderType,
    this.reminderDate,
    this.reminderTime,
    this.hasReminder = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "amount": amount,
    "category": category,
    "date": date.toIso8601String(),
    "note": note,

    "imageBase64": imageBase64,

    "reminderType": reminderType,
    "reminderDate":
    reminderDate?.toIso8601String(),

    // TimeOfDay saved as string "HH:mm"
    "reminderTime": reminderTime == null
        ? null
        : "${reminderTime!.hour}:${reminderTime!.minute}",

    "hasReminder": hasReminder,
  };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? t) {
      if (t == null) return null;
      final parts = t.split(":");
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return ExpenseModel(
      id: json["id"],
      title: json["title"] ?? "",
      amount: (json["amount"] as num).toDouble(),
      category: json["category"],
      date: DateTime.parse(json["date"]),
      note: json["note"] ?? "",

      imageBase64: json["imageBase64"],

      reminderType: json["reminderType"],
      reminderDate: json["reminderDate"] != null
          ? DateTime.parse(json["reminderDate"])
          : null,
      reminderTime: parseTime(json["reminderTime"]),
      hasReminder: json["hasReminder"] ?? false,
    );
  }
}