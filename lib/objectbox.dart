import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

    _addOthersCollectionAndInitCollections();
  }

  void _addOthersCollectionAndInitCollections() {
    if (collectionBox
            .query(Collection_.name.equals('Others'))
            .build()
            .count() ==
        0) {
      collectionBox.put(Collection(name: 'Others'));

      // Common Collections
      collectionBox.put(Collection(name: 'Fruits & Vegetables'));
      collectionBox.put(Collection(name: 'Dairy'));
      collectionBox.put(Collection(name: 'Bakery'));
      collectionBox.put(Collection(name: 'Meats'));
      collectionBox.put(Collection(name: 'Household'));
      collectionBox.put(Collection(name: 'Frozen'));
      collectionBox.put(Collection(name: 'Snacks'));
      collectionBox.put(Collection(name: 'Drinks'));
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
