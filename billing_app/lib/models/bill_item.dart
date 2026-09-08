import 'product.dart';

class BillItem {
  final Product product;
  int quantity;
  double unitPrice;

  BillItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  BillItem copyWith({
    Product? product,
    int? quantity,
    double? unitPrice,
  }) {
    return BillItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
