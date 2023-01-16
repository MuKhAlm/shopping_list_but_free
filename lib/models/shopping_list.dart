import 'package:objectbox/objectbox.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';

@Entity()
class ShoppingList {
  @Id()
  int id;
  final String name;

  @Backlink('shoppingList')
  final shoppingItems = ToMany<ShoppingItem>();

  ShoppingList({
    required this.name,
    this.id = 0,
  });
}
