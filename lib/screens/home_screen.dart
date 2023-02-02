import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';
import 'package:shopping_list_but_free/widgets/shopping_list_adding_card.dart';

/// A widget that displays the home screen
class HomeScreen extends StatefulWidget {
  /// Creates a home screen widget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final Stream<List<ShoppingList>> _shoppingListsStream = objectbox
      .shoppingListBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  bool _displayShoppingListAddingCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List But Free'),
      ),
      drawer: const Drawer(),
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<List<ShoppingList>>(
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => ShoppingListScreen(
                                      shoppingList: snapshot.data![index],
                                    )),
                              ),
                            );
                          },
                          title: Text(
                            snapshot.data![index].name,
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove shopping list',
                            onPressed: () {
                              objectbox.shoppingListBox
                                  .remove(snapshot.data![index].id);
                            },
                            icon: const Icon(
                              Icons.delete_forever_outlined,
                            ),
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
              },
            ),
            if (_displayShoppingListAddingCard)
              ShoppingListAddingCard(
                onBack: () {
                  setState(() {
                    _displayShoppingListAddingCard = false;
                  });
                },
              ),
          ],
        ),
      ),
      floatingActionButton: (_displayShoppingListAddingCard)
          ? null
          : FloatingActionButton(
              tooltip: 'Add a new shopping list',
              onPressed: () {
                setState(() {
                  _displayShoppingListAddingCard = true;
                });
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
