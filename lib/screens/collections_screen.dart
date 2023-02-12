import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late final Stream<List<Collection>> _collectionStream = objectbox
      .collectionBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      drawer: const MainNavigationDrawer(),
      body: StreamBuilder(
        stream: _collectionStream,
        builder: (context, collectionsSnapshot) {
          if (!collectionsSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Collection> collections =
              collectionsSnapshot.data as List<Collection>;

          return ListView(
            children: [
              ExpansionPanelList(
                children: collections.map((Collection collection) {
                  return ExpansionPanel(
                    isExpanded: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(collection.name),
                      );
                    },
                    body: Column(
                      children: collection.shoppingItemsNames
                          .map((String shoppingItemName) {
                        return ListTile(
                          title: Text(shoppingItemName),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
            ],
          );
        },
      ),
    );
  }
}
