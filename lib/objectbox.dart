import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

import 'objectbox.g.dart';

/// A link to ObjectBox database
late final ObjectBox objectbox;

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

    _addMockData();
  }

  void _addMockData() {
    // Empty collections
    shoppingItemBox.removeAll();
    shoppingListBox.removeAll();
    collectionBox.removeAll();
    if (collectionBox.isEmpty()) {
      Collection collection1 = Collection(name: 'Collection 1');
      collection1.shoppingItemsNames.add('shopping item 1');
      Collection collection2 = Collection(name: 'Collection 2');
      collection2.shoppingItemsNames.add('shopping item 2');

      collectionBox.put(collection1);
      collectionBox.put(collection2);
      collectionBox.put(Collection(name: 'Collection 3'));
    }

    if (shoppingListBox.isEmpty()) {
      ShoppingList shoppingList = ShoppingList(name: 'Shopping List 1');
      shoppingList.shoppingItems.add(ShoppingItem(name: 'Shopping Item 1'));
      shoppingList.shoppingItems.add(ShoppingItem(name: 'Shopping Item 2'));

      shoppingListBox.put(shoppingList);
      shoppingListBox.put(ShoppingList(name: 'Shopping List 2'));
      shoppingListBox.put(ShoppingList(name: 'Shopping List 3'));
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
