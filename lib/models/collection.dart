import 'package:objectbox/objectbox.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';

/// Models a collection of [ShoppingItem]s
@Entity()
class Collection {
  @Id()
  int id;
  String name;

  /// Names of all corresponding [shoppingItems] **(Not case sensitive)**.
  ///
  /// All items **must** be **lower-case**.
  Set<String> shoppingItemsNames = {};

  /// Creates an entity that works as a collection for [ShoppingItem]s by type.
  ///
  /// [id] is only to be assign by [ObjectBox].
  Collection({
    required this.name,
    this.id = 0,
  });
}
