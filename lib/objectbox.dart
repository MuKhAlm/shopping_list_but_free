import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

import 'objectbox.g.dart';

/// A class that represents the application's database
class ObjectBox {
  late final Store _store;

  late final Box<ShoppingList> shoppingListBox;
  late final Box<ShoppingItem> shoppingItemBox;
  late final Box<Collection> collectionBox;

  /// Initializes entity boxes
  ObjectBox._open(this._store) {
    shoppingListBox = Box<ShoppingList>(_store);
    shoppingItemBox = Box<ShoppingItem>(_store);
    collectionBox = Box<Collection>(_store);

    if (shoppingListBox.isEmpty()) {
      shoppingListBox.put(ShoppingList(name: 'Shopping List 1'));
    }
  }

  /// Creates an ObjectBox database at appropriate location
  static Future<ObjectBox> open() async {
    final documentDir = await getApplicationDocumentsDirectory();
    final dataBaseDir = p.join(documentDir.path, 'obx-db');

    final store = await openStore(directory: dataBaseDir);
    return ObjectBox._open(store);
  }
}
