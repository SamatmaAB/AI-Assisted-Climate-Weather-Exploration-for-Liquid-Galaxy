import 'package:flutter/material.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('User Guide'),
            trailing: const Icon(Icons.open_in_new_outlined, size: 18),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version 1.0.0 (Beta)'),
            subtitle: const Text('Liquid Galaxy Earth Systems Explorer'),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('Open Source Code'),
            trailing: const Icon(Icons.open_in_new_outlined, size: 18),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
