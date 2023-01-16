import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';

void main() {
  const String name = 'test shopping item';
  final testShoppingItem = ShoppingItem(name: name);
  group('ShoppingItem', () {
    test('Assign correct value for [name] field', () {
      expect(testShoppingItem.name, name);
    });

    test('Assign correct default value for [checked] field', () {
      expect(testShoppingItem.checked, false);
    });

    test('Assign correct default value for [quantity] field', () {
      expect(testShoppingItem.quantity, 1);
    });
  });
}
