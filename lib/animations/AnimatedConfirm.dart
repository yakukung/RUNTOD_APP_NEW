import 'package:flutter/material.dart';

class Animatedconfirm extends StatefulWidget {
  const Animatedconfirm({super.key});

  @override
  State<Animatedconfirm> createState() => _AnimatedconfirmState();
}

class _AnimatedconfirmState extends State<Animatedconfirm> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                // Add your logout logic here
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout Confirmation Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showLogoutDialog,
          child: Text('Logout'),
        ),
      ),
    );
  }
}
