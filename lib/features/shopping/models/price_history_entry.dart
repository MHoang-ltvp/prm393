class PriceHistoryEntry {
  PriceHistoryEntry({
    required this.id,
    required this.name,
    required this.unit,
    required this.market,
    required this.price,
  });

  final String id;
  final String name;
  final String unit;
  final String market;
  final double price;

  PriceHistoryEntry copyWith({
    String? id,
    String? name,
    String? unit,
    String? market,
    double? price,
  }) {
    return PriceHistoryEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      market: market ?? this.market,
      price: price ?? this.price,
    );
  }
}
