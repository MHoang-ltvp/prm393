class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    required this.market,
    required this.category,
    this.isBought = false,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double estimatedPrice;
  final String market;
  final String category;
  bool isBought;

  double get total => quantity * estimatedPrice;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'estimatedPrice': estimatedPrice,
      'market': market,
      'category': category,
      'isBought': isBought,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      market: json['market'] as String,
      category: json['category'] as String,
      isBought: json['isBought'] as bool? ?? false,
    );
  }
}
