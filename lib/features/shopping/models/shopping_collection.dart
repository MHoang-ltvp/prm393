import 'package:tet_shop/features/shopping/models/shopping_item.dart';

class ShoppingCollection {
  ShoppingCollection({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  String name;
  final List<ShoppingItem> items;
}
