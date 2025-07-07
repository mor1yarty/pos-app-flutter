import 'purchase_item.dart';

class Transaction {
  final int? transactionId;
  final DateTime dateTime;
  final String employeeCode;
  final String storeCode;
  final String posNo;
  final int totalAmount;
  final List<PurchaseItem> items;

  const Transaction({
    this.transactionId,
    required this.dateTime,
    required this.employeeCode,
    required this.storeCode,
    required this.posNo,
    required this.totalAmount,
    required this.items,
  });

  factory Transaction.fromPurchaseItems({
    required List<PurchaseItem> items,
    String employeeCode = '9999999999',
    String storeCode = '30',
    String posNo = '90',
  }) {
    final totalAmount = items.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    return Transaction(
      dateTime: DateTime.now(),
      employeeCode: employeeCode,
      storeCode: storeCode,
      posNo: posNo,
      totalAmount: totalAmount,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': dateTime.toIso8601String(),
      'emp_cd': employeeCode,
      'store_cd': storeCode,
      'pos_no': posNo,
      'total_amt': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Transaction{transactionId: $transactionId, dateTime: $dateTime, employeeCode: $employeeCode, storeCode: $storeCode, posNo: $posNo, totalAmount: $totalAmount, items: ${items.length}}';
  }
}