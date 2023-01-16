import 'package:objectbox/objectbox.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';

@Entity()
class Collection {
  @Id()
  int id;
  String name;

  @Backlink('collection')
  List<ShoppingItem> shoppingItems = ToMany<ShoppingItem>();

  Collection({
    required this.name,
    this.id = 0,
  });
}
