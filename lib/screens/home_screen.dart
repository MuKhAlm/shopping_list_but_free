import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/default_icons.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_list.dart';
import 'package:shopping_list_but_free/widgets/import_shopping_list.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

/// A widget that displays the home screen
class HomeScreen extends StatelessWidget {
  final Stream<List<ShoppingList>> _shoppingListsStream = objectbox
      .shoppingListBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List But Free'),
        actions: [
          IconButton(
            tooltip: 'Import',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => const ImportShoppingList()),
              );
            },
            icon: const Icon(Icons.download_outlined),
          )
        ],
      ),
      drawer: const MainNavigationDrawer(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new shopping list',
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => const AddShoppingList(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => ShoppingListScreen(
                                  shoppingListId: snapshot.data![index].id,
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
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(
                          defaultDeleteIcon,
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
      ),
    );
  }
}
