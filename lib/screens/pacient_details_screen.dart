import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:postopcare/data/repositories/pacient_repository/pacient_repository.dart';
import 'package:postopcare/data/repositories/surgery_repository/surgery_repository.dart';
import 'package:postopcare/data/repositories/surgery_templates_repository/surgery_templates_repository.dart';
import 'package:postopcare/data/repositories/appointment_repository/appointment_repository.dart';
import 'surgery_screen.dart'; // import pentru ecranul detaliat

class PacientDetailScreen extends StatefulWidget {
  final String userId;
  final Pacient pacient;

  const PacientDetailScreen({
    super.key,
    required this.userId,
    required this.pacient,
  });

  @override
  State<PacientDetailScreen> createState() => _PacientDetailScreenState();
}

class _PacientDetailScreenState extends State<PacientDetailScreen> {
  late SurgeryRepository _surgeryRepo;
  late Future<List<Surgery>> _surgeriesFuture;
  late SurgeryTemplateRepository _templateRepo;
  late PatientRepository _patientRepo;
  late Pacient _pacient;

  late TextEditingController _numeController;
  late TextEditingController _varstaController;
  late TextEditingController _telefonController;
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    _pacient = widget.pacient;

    _surgeryRepo = SurgeryRepository(
      userId: widget.userId,
      pacientId: _pacient.id,
    );
    _templateRepo = SurgeryTemplateRepository(userId: widget.userId);
    _patientRepo = PatientRepository(userId: widget.userId);

    _numeController = TextEditingController(text: _pacient.nume);
    _varstaController = TextEditingController(text: _pacient.varsta.toString());
    _telefonController = TextEditingController(text: _pacient.telefon ?? '');
    _selectedSex = _pacient.sex;

    _loadSurgeries();
  }

  void _loadSurgeries() {
    setState(() {
      _surgeriesFuture = _surgeryRepo.getSurgeries();
    });
  }

  Future<void> _addSurgeryFromTemplate() async {
    try {
      final templates = await _templateRepo.getAllTemplates();

      final selectedTemplate = await showDialog<SurgeryTemplate>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Selectează un template de operație'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return ListTile(
                    title: Text(template.name),
                    onTap: () => Navigator.of(context).pop(template),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text('Anulează'),
              ),
            ],
          );
        },
      );

      if (selectedTemplate == null) return;

      final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (selectedDate == null) return;

      final surgery = Surgery(
        id: '',
        nume: selectedTemplate.name,
        dataEfectuarii: selectedDate,
        templateId: selectedTemplate.id,
        appointments: [],
      );

      final docRef = await _surgeryRepo.addSurgeryReturnDocRef(surgery);

      final appointmentRepo = AppointmentRepository(
        userId: widget.userId,
        pacientId: _pacient.id,
        surgeryId: docRef.id,
      );

      for (final weekInterval in selectedTemplate.intervals) {
        final estimatedDate = selectedDate.add(
          Duration(days: weekInterval * 7),
        );
        final appointment = Appointment(id: '', date: estimatedDate, time: '');
        await appointmentRepo.addAppointment(appointment);
      }

      _loadSurgeries();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la adăugarea operației: $e')),
      );
    }
  }

  void _showEditPacientDialog() {
    String? selectedSex = _selectedSex; // variabilă locală pentru dialog

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Editează pacient'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _numeController,
                      decoration: InputDecoration(labelText: 'Nume'),
                    ),
                    TextField(
                      controller: _varstaController,
                      decoration: InputDecoration(labelText: 'Vârstă'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    TextField(
                      controller: _telefonController,
                      decoration: InputDecoration(
                        labelText: 'Număr de telefon',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                    ),
                    SizedBox(height: 10),
                    Text('Sex:'),
                    Wrap(
                      spacing: 10,
                      children:
                          ['M', 'F'].map((value) {
                            final isSelected = selectedSex == value;
                            return ChoiceChip(
                              label: Text(value),
                              selected: isSelected,
                              selectedColor: Colors.teal,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setStateDialog(() {
                                    selectedSex = value;
                                  });
                                }
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // anulare
                  child: Text('Anulează'),
                ),
                TextButton(
                  onPressed: () {
                    final nume = _numeController.text.trim();
                    final varsta =
                        int.tryParse(_varstaController.text.trim()) ?? 0;
                    final telefon = _telefonController.text.trim();

                    if (nume.isEmpty ||
                        selectedSex == null ||
                        varsta <= 0 ||
                        telefon.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Completează toate câmpurile corect (telefon 10 cifre).',
                          ),
                        ),
                      );
                      return;
                    }

                    final updatedPacient = Pacient(
                      id: _pacient.id,
                      nume: nume,
                      varsta: varsta,
                      sex: selectedSex!,
                      telefon: telefon,
                    );

                    _patientRepo
                        .updatePacient(updatedPacient)
                        .then((_) {
                          setState(() {
                            _pacient = updatedPacient;
                            _selectedSex =
                                selectedSex; // actualizează starea părinte
                          });
                          Navigator.of(context).pop();
                        })
                        .catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Eroare la actualizare: $e'),
                            ),
                          );
                        });
                  },
                  child: Text('Salvează'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmare ștergere'),
            content: Text('Sigur vrei să ștergi pacientul ${_pacient.nume}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Anulează'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _patientRepo.deletePacient(_pacient.id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Eroare la ștergere: $e')),
                    );
                  }
                },
                child: Text('Șterge', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacient = _pacient;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditPacientDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/medical_image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 10, 221, 221).withOpacity(0.8),
                    Color.fromARGB(255, 10, 221, 221).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pacient.nume,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Vârstă: ${pacient.varsta}',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(width: 30),
                        Text(
                          'Sex: ${pacient.sex}',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(width: 30),
                        Icon(Icons.phone, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          '${pacient.telefon}',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Operații efectuate',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 10, 221, 221),
                        ),
                      ),
                      Material(
                        color: Color.fromARGB(255, 10, 221, 221),
                        shape: CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: _addSurgeryFromTemplate,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<Surgery>>(
                      future: _surgeriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Eroare la încărcarea operațiilor',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final surgeries = snapshot.data ?? [];
                        if (surgeries.isEmpty) {
                          return Center(
                            child: Text(
                              'Nu există operații',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: surgeries.length,
                          separatorBuilder:
                              (context, index) => Divider(
                                color: const Color.fromARGB(255, 196, 252, 230),
                              ),
                          itemBuilder: (context, index) {
                            final surgery = surgeries[index];
                            final formattedDate = DateFormat(
                              'dd.MM.yyyy',
                            ).format(surgery.dataEfectuarii);
                            return Card(
                              color: const Color.fromARGB(
                                255,
                                190,
                                246,
                                231,
                              ).withOpacity(0.9),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  surgery.nume,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Data: $formattedDate'),
                                onTap: () async {
                                  final result = await Navigator.of(
                                    context,
                                  ).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SurgeryDetailScreen(
                                            userId: widget.userId,
                                            pacientId: _pacient.id,
                                            surgery: surgery,
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadSurgeries();
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
