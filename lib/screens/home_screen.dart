import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/main.dart' show objectbox;
import 'package:shopping_list_but_free/models/shopping_list.dart';

/// A widget that displays the home screen
class HomeScreen extends StatefulWidget {
  /// Creates a home screen widget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<List<ShoppingList>> _shoppingListsStream = objectbox
      .shoppingListBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List But Free'),
      ),
      drawer: const Drawer(),
      body: SafeArea(
        child: StreamBuilder<List<ShoppingList>>(
            stream: _shoppingListsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return ListView.separated(
                itemBuilder: ((context, index) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        title: Text(
                          snapshot.data![index].name,
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove Shopping List',
                          onPressed: () {},
                          icon: const Icon(Icons.remove_circle_sharp),
                        ),
                      ),
                      if (index == snapshot.data!.length - 1)
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
                        ),
                    ],
                  );
                }),
                separatorBuilder: ((context, index) => const Divider()),
                itemCount: snapshot.data!.length,
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new shopping list',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
