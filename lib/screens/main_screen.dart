import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postopcare/widgets/calendar.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/widgets/sidebar.dart';
import 'package:postopcare/data/models/appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  final AppUser user;

  MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> programari = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true; // variabilă pentru stare loading

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _fetchProgramariForDay(today);
  }

  Future<void> _fetchProgramariForDay(DateTime selectedDay) async {
    setState(() {
      programari = [];
      _isLoading = true; // start loading
    });

    if (widget.user.id == null) {
      print('User ID is null!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final allAppointments = await _getAllAppointmentsForUser(widget.user.id!);

      final filtered =
          allAppointments.where((appointment) {
            final date = appointment.date;
            return date.year == selectedDay.year &&
                date.month == selectedDay.month &&
                date.day == selectedDay.day;
          }).toList();

      final programariForDay =
          filtered.map((appointment) {
            return {
              'tip_operatie': appointment.surgeryName,
              'date': appointment.date,
              'time': appointment.time,
              'nume_pacient':
                  appointment.patientName ?? 'Nume pacient necunoscut',
            };
          }).toList();

      setState(() {
        programari = programariForDay;
        _isLoading = false; // loading gata
      });
    } catch (e) {
      print('Eroare la încărcarea programărilor: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Appointment>> _getAllAppointmentsForUser(String userId) async {
    final firestore = FirebaseFirestore.instance;
    List<Appointment> allAppointments = [];

    try {
      final pacientSnapshot =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('pacients')
              .get();

      for (final pacientDoc in pacientSnapshot.docs) {
        final pacientId = pacientDoc.id;
        final pacientData = pacientDoc.data();
        final pacientName = pacientData['nume'] ?? 'Nume pacient necunoscut';

        final surgeriesSnapshot =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('pacients')
                .doc(pacientId)
                .collection('surgeries')
                .get();

        for (final surgeryDoc in surgeriesSnapshot.docs) {
          final surgeryData = surgeryDoc.data();
          final surgeryName = surgeryData['nume'] ?? 'Operație';

          final appointmentsSnapshot =
              await firestore
                  .collection('users')
                  .doc(userId)
                  .collection('pacients')
                  .doc(pacientId)
                  .collection('surgeries')
                  .doc(surgeryDoc.id)
                  .collection('appointments')
                  .get();

          for (final appointmentDoc in appointmentsSnapshot.docs) {
            final data = appointmentDoc.data();
            final timestamp = data['date'] as Timestamp?;
            final date = timestamp?.toDate() ?? DateTime.now();

            final time = data['time'] ?? '';

            allAppointments.add(
              Appointment(
                id: appointmentDoc.id,
                date: date,
                time: time,
                surgeryName: surgeryName,
                patientName: pacientName,
              ),
            );
          }
        }
      }
      return allAppointments;
    } catch (e) {
      print('Error fetching all appointments for user: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
        backgroundColor: Color.fromARGB(255, 10, 221, 221),
        automaticallyImplyLeading: false,
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: CustomDrawer(user: widget.user),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Today's Schedule:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          CalendarWidget(
            onDaySelected: (selectedDay) {
              _fetchProgramariForDay(selectedDay);
            },
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : programari.isEmpty
                    ? Center(
                      child: Text(
                        'Nicio programare',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            programari.map((programare) {
                              final dateFormat = DateFormat('yyyy-MM-dd');
                              return Card(
                                margin: EdgeInsets.symmetric(
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
                                    '${programare['nume_pacient']} - ${dateFormat.format(programare['date'])} - ${programare['time']}',
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
    );
  }
}
