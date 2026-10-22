import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Campus events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                Navigator.pop(context); // close the drawer first (R32)
                onAbout();
              },
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restart_alt),
              onTap: () {
                Navigator.pop(context);
                onReset();
              },
            ),
          ],
        ),
      ),
    );
  }
}
