import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainNavigationDrawer extends StatelessWidget {
  const MainNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * (2 / 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: const [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'Navigation Menu',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_sharp),
                title: Text('Home'),
              ),
              ListTile(
                leading: Icon(Icons.square_outlined),
                title: Text('Collections'),
              ),
            ],
          ),
          Column(
            children: const [
              Divider(),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.github),
                title: Text('Source Code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
