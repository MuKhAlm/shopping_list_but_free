import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

void main() {
  group('ShoppingList', () {
    test('Assign correct value for [name] field', () {
      String name = 'test shopping list';
      ShoppingList testShoppingList = ShoppingList(name: name);

      expect(testShoppingList.name, name);
    });
  });
}
