import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class MyDrawer extends StatelessWidget {
  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      // RichText(),
      Linkify(
        onOpen: _onOpen,
        text: "GitHub: https://github.com/Sciroccogti/foldest\n",
      ),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          AboutListTile(
            icon: const Icon(Icons.info),
            applicationIcon: const FlutterLogo(),
            // TODO: substitute
            applicationName: 'Foldest',
            applicationVersion: 'v3.0',
            applicationLegalese: 'Made with love by Sciroccogti',
            aboutBoxChildren: aboutBoxChildren,
          ),
        ],
      ),
    );
  }
}
