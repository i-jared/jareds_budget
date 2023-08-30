import 'package:budget/state/home.dart';

class Transaction {
  final String description;
  final Category category;
  final double amount;
  final DateTime date;

  const Transaction(
      {required this.description,
      required this.category,
      required this.amount,
      required this.date});
}
