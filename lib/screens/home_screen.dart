import 'package:flutter/material.dart';

/// A widget that displays the home screen
class HomeScreen extends StatelessWidget {
  /// Creates a home screen widget
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> shoppingLists = [];
    for (var i = 1; i <= 20; i++) {
      shoppingLists.add('Shopping List $i');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List But Free'),
      ),
      drawer: const Drawer(),
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: ((context, index) {
            return Column(
              children: [
                ListTile(
                  onTap: () {},
                  title: Text(
                    shoppingLists[index],
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove Shopping List',
                    onPressed: () {},
                    icon: const Icon(Icons.remove_circle_sharp),
                  ),
                ),
                if (index == shoppingLists.length - 1)
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 5,
                  ),
              ],
            );
          }),
          separatorBuilder: ((context, index) => const Divider()),
          itemCount: shoppingLists.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new shopping list',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
