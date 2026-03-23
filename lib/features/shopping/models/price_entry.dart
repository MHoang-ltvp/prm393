class PriceEntry {
  PriceEntry({
    required this.market,
    required this.price,
  });

  final String market;
  final double price;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'market': market, 'price': price};
  }

  factory PriceEntry.fromJson(Map<String, dynamic> json) {
    return PriceEntry(
      market: json['market'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}
