// import 'package:flutter/material.dart';
// import 'package:postopcare/widgets/calendar.dart';
// import 'package:postopcare/data/models/user.dart';
// import 'package:postopcare/widgets/sidebar.dart'; // Import CustomDrawer

// class MainScreen extends StatelessWidget {
//   final AppUser user;

//   // Crearea unui GlobalKey pentru a controla Scaffold-ul
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   // Constructor pentru a primi utilizatorul
//   MainScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey, // Setăm key-ul pentru Scaffold
//       appBar: AppBar(
//         // title in the center
//         title: Center(
//           child: Text(
//             'PostopCare',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         backgroundColor: const Color.fromARGB(255, 10, 221, 221),
//         // Elimină butonul implicit din stânga care se folosește pentru back
//         automaticallyImplyLeading: false,
//         // Mută butonul de meniul de tip hamburger în partea stângă
//         leading: IconButton(
//           color: Colors.white,
//           icon: const Icon(Icons.menu),
//           onPressed: () {
//             // Deschide Drawer-ul (Sidebar-ul)
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Today\'s Schedule:',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           // Calendarul pentru selectarea zilei
//           const Expanded(
//             child: CalendarWidget(), // Widgetul Calendarului
//           ),
//         ],
//       ),
//       // Sidebar (Drawer) folosind CustomDrawer
//       drawer: CustomDrawer(user: user),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:postopcare/widgets/calendar.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/widgets/sidebar.dart'; // Import CustomDrawer
import 'package:intl/intl.dart'; // Import pentru DateFormat

class MainScreen extends StatefulWidget {
  final AppUser user;

  // Constructor pentru a primi utilizatorul
  MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> programari = [];
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Definirea key-ului pentru Scaffold

  // Funcția care va aduce programările din Firebase
  Future<void> _fetchProgramariForDay(DateTime selectedDay) async {
    // Simulăm datele pentru a face testarea
    setState(() {
      programari = [
        {
          'tip_operatie': 'Consultație generală',
          'date': selectedDay.add(Duration(hours: 8)),
        },
        {
          'tip_operatie': 'Examinare post-operatorie',
          'date': selectedDay.add(Duration(hours: 10)),
        },
        {
          'tip_operatie': 'Întâlnire cu medicul de specialitate',
          'date': selectedDay.add(Duration(hours: 12)),
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Setăm key-ul pentru Scaffold
      appBar: AppBar(
        // Title în centru
        title: Center(
          child: Text(
            'PostopCare',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 221, 221),
        // Elimină butonul implicit din stânga care se folosește pentru back
        automaticallyImplyLeading: false,
        // Mută butonul de meniul de tip hamburger în partea stângă
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Deschide Drawer-ul (Sidebar-ul)
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
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
          CalendarWidget(
            onDaySelected: (selectedDay) {
              _fetchProgramariForDay(
                selectedDay,
              ); // Fetch programările pentru ziua selectată
            },
          ),
          // Afișează programările pentru ziua selectată
          Expanded(
            child:
                programari.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Loading
                    : SingleChildScrollView(
                      // Permite derularea dacă sunt prea multe programări
                      child: Column(
                        children:
                            programari.map((programare) {
                              final dateFormat = DateFormat(
                                'yyyy-MM-dd – HH:mm',
                              );
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    programare['tip_operatie'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dateFormat.format(
                                      programare['date'],
                                    ), // Afișează data și ora
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
      // Sidebar (Drawer) folosind CustomDrawer
      drawer: CustomDrawer(user: widget.user),
    );
  }
}
