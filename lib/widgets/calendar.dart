// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarWidget extends StatefulWidget {
//   const CalendarWidget({super.key});

//   @override
//   State<CalendarWidget> createState() => _CalendarWidgetState();
// }

// class _CalendarWidgetState extends State<CalendarWidget> {
//   late ValueNotifier<DateTime> _selectedDay;
//   late ValueNotifier<DateTime> _focusedDay;

//   @override
//   void initState() {
//     super.initState();
//     _focusedDay = ValueNotifier(DateTime.now());
//     _selectedDay = ValueNotifier(DateTime.now());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ValueListenableBuilder(
//           valueListenable: _selectedDay,
//           builder: (context, DateTime selectedDay, _) {
//             return TableCalendar(
//               focusedDay: _focusedDay.value,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDay.value = selectedDay;
//                   _focusedDay.value = focusedDay;
//                 });
//               },
//               onPageChanged: (focusedDay) {
//                 _focusedDay.value = focusedDay;
//               },
//               firstDay: DateTime(2020, 1, 1), // Prima zi din calendar
//               lastDay: DateTime(2025, 12, 31), // Ultima zi din calendar
//             );
//           },
//         ),
//         const SizedBox(height: 20),
//         _buildProgramForDay(_selectedDay.value),
//       ],
//     );
//   }

//   // Funcție pentru a construi programul zilei selectate
//   Widget _buildProgramForDay(DateTime day) {
//     // Aici vei obține datele programului pentru acea zi din Firebase sau altă sursă
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Programul pentru ${day.day}/${day.month}/${day.year}:',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         // Aici adaugi o listă cu programul (exemplu de date)
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('08:00 - Consultație generală'),
//               Text('10:00 - Examinare post-operatorie'),
//               Text('12:00 - Întâlnire cu medicul de specialitate'),
//               // Acestea sunt doar exemple, aici vei înlocui cu datele reale
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _selectedDay.dispose();
//     _focusedDay.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDaySelected; // Funcție pentru ziua selectată

  const CalendarWidget({super.key, required this.onDaySelected});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late ValueNotifier<DateTime> _selectedDay;
  late ValueNotifier<DateTime> _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(DateTime.now());
    _selectedDay = ValueNotifier(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _selectedDay,
          builder: (context, DateTime selectedDay, _) {
            return TableCalendar(
              focusedDay: _focusedDay.value,
              selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay.value = selectedDay;
                  _focusedDay.value = focusedDay;
                });
                widget.onDaySelected(selectedDay); // Apelăm funcția transmisă
              },
              onPageChanged: (focusedDay) {
                _focusedDay.value = focusedDay;
              },
              firstDay: DateTime(2020, 1, 1), // Prima zi din calendar
              lastDay: DateTime(2025, 12, 31), // Ultima zi din calendar
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _selectedDay.dispose();
    _focusedDay.dispose();
    super.dispose();
  }
}
