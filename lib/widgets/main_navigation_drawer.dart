import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopping_list_but_free/screens/about_screen.dart';
import 'package:shopping_list_but_free/screens/collections_screen.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    'Navigation Menu',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_sharp),
                title: const Text('Home'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.square_outlined),
                title: const Text('Collections'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CollectionsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          Column(
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.github),
                title: const Text('Source Code'),
                onTap: _launchSourceCodeUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchSourceCodeUrl() async {
    Uri url =
        Uri.parse('https://github.com/MuKhAlt/shopping_list_but_free.git');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
