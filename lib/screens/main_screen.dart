import 'package:flutter/material.dart';
import 'package:postopcare/widgets/calendar.dart';
import 'package:postopcare/data/models/user.dart';

class MainScreen extends StatelessWidget {
  final AppUser user;

  // Constructor pentru a primi utilizatorul
  const MainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user.name}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Logica pentru a deschide sidebar-ul
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Schedule:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Calendarul pentru selectarea zilei
          const Expanded(
            child: CalendarWidget(), // Widgetul Calendarului
          ),
        ],
      ),
    );
  }
}
