import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postopcare/data/models/appointment.dart';
import 'package:postopcare/data/models/surgery.dart';
import 'package:postopcare/data/repositories/appointment_repository/appointment_repository.dart';

class SurgeryDetailScreen extends StatefulWidget {
  final Surgery surgery;
  final String userId;
  final String pacientId;

  const SurgeryDetailScreen({
    super.key,
    required this.surgery,
    required this.userId,
    required this.pacientId,
  });

  @override
  State<SurgeryDetailScreen> createState() => _SurgeryDetailScreenState();
}

class _SurgeryDetailScreenState extends State<SurgeryDetailScreen> {
  late AppointmentRepository _appointmentRepo;
  List<Appointment> _appointments = [];
  List<Appointment> _allTakenAppointments = [];

  @override
  void initState() {
    super.initState();
    _appointmentRepo = AppointmentRepository(
      userId: widget.userId,
      pacientId: widget.pacientId,
      surgeryId: widget.surgery.id,
    );
    _loadAppointments();
    _loadAllTakenAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointments = await _appointmentRepo.getAppointments();
    setState(() {
      _appointments = appointments;
    });
  }

  Future<void> _loadAllTakenAppointments() async {
    final all = await AppointmentRepository.getAllAppointments(widget.userId);
    setState(() {
      _allTakenAppointments = all;
    });
  }

  Future<void> _onAppointmentTap(int index) async {
    final appointment = _appointments[index];
    final templateDate = appointment.date;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: templateDate,
      firstDate: templateDate.subtract(Duration(days: 3)),
      lastDate: templateDate.add(Duration(days: 3)),
      selectableDayPredicate:
          (day) =>
              day.weekday != DateTime.saturday &&
              day.weekday != DateTime.sunday,
    );

    if (selectedDate == null) return;

    final selectedTime = await _pickValidHour(context);
    if (selectedTime == null) return;

    final updatedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
    );

    final isTaken = _allTakenAppointments.any(
      (taken) =>
          taken.date.year == updatedDateTime.year &&
          taken.date.month == updatedDateTime.month &&
          taken.date.day == updatedDateTime.day &&
          taken.time == selectedTime.format(context),
    );

    if (isTaken) {
      final suggestion = await _findNextAvailableSlot(
        selectedDate,
        _allTakenAppointments,
      );
      final suggestionText =
          suggestion != null
              ? 'Try ${DateFormat('dd.MM.yyyy').format(suggestion.date)} at ${suggestion.time}'
              : 'No available time slots found soon.';

      await _showInvalidTimeDialog(
        context,
        'Selected time is already taken.\n$suggestionText',
      );
      return;
    }

    final updatedAppointment = Appointment(
      id: appointment.id,
      date: selectedDate,
      time: selectedTime.format(context),
    );

    await _appointmentRepo.updateAppointment(updatedAppointment);
    _loadAppointments();
  }

  Future<TimeOfDay?> _pickValidHour(BuildContext context) async {
    while (true) {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (picked == null) return null;

      if (picked.minute != 0) {
        await _showInvalidTimeDialog(context, 'Minutes must be 00');
        continue;
      }

      if (picked.hour < 9 || picked.hour > 17) {
        await _showInvalidTimeDialog(
          context,
          'Hour must be between 09:00 and 17:00',
        );
        continue;
      }

      return picked;
    }
  }

  Future<void> _showInvalidTimeDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Invalid time'),
            content: Text(message, style: TextStyle(color: Colors.red)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Choose again'),
              ),
            ],
          ),
    );
  }

  Future<Appointment?> _findNextAvailableSlot(
    DateTime startDate,
    List<Appointment> taken,
  ) async {
    const startHour = 9;
    const endHour = 17;

    for (int dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final date = startDate.add(Duration(days: dayOffset));

      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      for (int hour = startHour; hour <= endHour; hour++) {
        final timeOfDay = TimeOfDay(hour: hour, minute: 0);
        final timeString = timeOfDay.format(context);

        final isBusy = taken.any(
          (a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day &&
              a.time == timeString,
        );

        if (!isBusy) {
          return Appointment(id: '', date: date, time: timeString);
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formattedSurgeryDate = DateFormat(
      'dd.MM.yyyy',
    ).format(widget.surgery.dataEfectuarii);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surgery.nume),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Surgery Date: $formattedSurgeryDate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 24),
            Text(
              'Appointments:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_appointments.length, (index) {
                    final appointment = _appointments[index];
                    final formattedDate = DateFormat(
                      'dd.MM.yyyy',
                    ).format(appointment.date);

                    return GestureDetector(
                      onTap: () => _onAppointmentTap(index),
                      child: Container(
                        width: 100,
                        height: 80,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              appointment.time.isNotEmpty
                                  ? appointment.time
                                  : '--:--',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
