import 'package:objectbox/objectbox.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';

/// Models a shopping list
@Entity()
class ShoppingList {
  @Id()
  int id;
  final String name;

  @Backlink('shoppingList')
  final shoppingItems = ToMany<ShoppingItem>();

  /// Creates a shopping list entity,
  ///
  /// [id] must only be assigned by[ObjectBox]
  ShoppingList({
    required this.name,
    this.id = 0,
  });

  Map toJson() => {
        'name': name,
        'shoppingItems': shoppingItems.map((si) => si.toJson()).toList(),
      };
}
