import 'bill_item.dart';

class Bill {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime date;
  final List<BillItem> items;
  final double discountPercent;
  final double advancePaid;
  final String notes;

  Bill({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress = '',
    required this.date,
    required this.items,
    this.discountPercent = 0.0,
    this.advancePaid = 0.0,
    this.notes = '',
  });

  int get totalItemsCount => items.length;

  int get totalPiecesCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * (discountPercent / 100);

  double get grandTotal => (subtotal - discountAmount).clamp(0.0, double.infinity);

  double get balanceDue => (grandTotal - advancePaid).clamp(0.0, double.infinity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'discountPercent': discountPercent,
        'advancePaid': advancePaid,
        'notes': notes,
      };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] as String,
        customerName: json['customerName'] as String? ?? 'Customer',
        customerPhone: json['customerPhone'] as String? ?? '',
        customerAddress: json['customerAddress'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => BillItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
        advancePaid: (json['advancePaid'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );
}
