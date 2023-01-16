import 'package:objectbox/objectbox.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

/// Models a shopping item
@Entity()
class ShoppingItem {
  @Id()
  int id;
  final String name;
  bool checked;

  /// Quantity to be purchased, defaults to 1.
  int quantity;

  final ToOne<ShoppingList> shoppingList = ToOne<ShoppingList>();
  ToOne<Collection> collection = ToOne<Collection>();

  ShoppingItem({
    required this.name,
    this.checked = false,
    this.quantity = 1,
    this.id = 0,
  });
}
