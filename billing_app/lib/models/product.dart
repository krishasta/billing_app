class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String? subtitle;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.unit = 'Box',
    this.subtitle,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'unit': unit,
        'subtitle': subtitle,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'General',
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String? ?? 'Box',
        subtitle: json['subtitle'] as String?,
      );

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? subtitle,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
