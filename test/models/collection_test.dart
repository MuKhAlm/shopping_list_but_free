import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_but_free/models/collection.dart';

void main() {
  const String name = 'test collection';
  final Collection testCollection = Collection(name: name);
  group('Collection', () {
    test('Assign correct value for [name] field', () {
      expect(testCollection.name, name);
    });
  });
}
