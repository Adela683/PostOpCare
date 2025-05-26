import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:postopcare/data/models/pacient.dart';
import 'package:postopcare/data/repositories/pacient_repository/pacient_repository.dart';
import 'package:postopcare/data/repositories/surgery_repository/surgery_repository.dart';

class PacientDetailScreen extends StatefulWidget {
  final String userId;
  final Pacient pacient;

  const PacientDetailScreen({super.key, required this.userId, required this.pacient});

  @override
  State<PacientDetailScreen> createState() => _PacientDetailScreenState();
}

class _PacientDetailScreenState extends State<PacientDetailScreen> {
  late SurgeryRepository _surgeryRepo;
  late Future<List<Surgery>> _surgeriesFuture;
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
    _surgeryRepo = SurgeryRepository(userId: widget.userId, pacientId: _pacient.id);
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

  void _showEditPacientDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
                  decoration: InputDecoration(labelText: 'Număr de telefon'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                ),
                SizedBox(height: 10),
                Text('Sex:'),
                Wrap(
                  spacing: 10,
                  children: ['M', 'F'].map((value) {
                    return ChoiceChip(
                      label: Text(value),
                      selected: _selectedSex == value,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: _selectedSex == value ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedSex = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final nume = _numeController.text.trim();
                final varsta = int.tryParse(_varstaController.text.trim()) ?? 0;
                final telefon = _telefonController.text.trim();

                if (nume.isEmpty || _selectedSex == null || varsta <= 0 || telefon.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Completează toate câmpurile corect (telefon 10 cifre).')),
                  );
                  return;
                }

                final updatedPacient = Pacient(
                  id: _pacient.id,
                  nume: nume,
                  varsta: varsta,
                  sex: _selectedSex!,
                  telefon: telefon,
                );

                try {
                  await _patientRepo.updatePacient(updatedPacient);
                  setState(() {
                    _pacient = updatedPacient;
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Eroare la actualizare: $e')),
                  );
                }
              },
              child: Text('Salvează'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Anulează'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmare ștergere'),
        content: Text('Sigur vrei să ștergi pacientul ${_pacient.nume}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Anulează'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _patientRepo.deletePacient(_pacient.id);
                Navigator.of(context).pop(); // închide dialogul
                Navigator.of(context).pop(true); // închide ecranul detaliu
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
                    const Color.fromARGB(255, 10, 221, 221).withOpacity(0.8),
                    const Color.fromARGB(255, 10, 221, 221).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pacient.nume,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 1))],
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
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        pacient.telefon ?? '',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ],
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                          color: const Color.fromARGB(255, 10, 221, 221),
                        ),
                      ),
                      Material(
                        color: const Color.fromARGB(255, 10, 221, 221),
                        shape: CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            // TODO: Adăugare operație
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Expanded(
                    child: FutureBuilder<List<Surgery>>(
                      future: _surgeriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Colors.teal));
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
                          separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                          itemBuilder: (context, index) {
                            final surgery = surgeries[index];
                            final formattedDate = DateFormat('dd.MM.yyyy').format(surgery.dataEfectuarii);
                            return ListTile(
                              title: Text(
                                surgery.nume,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Data: $formattedDate'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.teal[700]),
                                    onPressed: () {
                                      // TODO: Editare operatie
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red[400]),
                                    onPressed: () {
                                      // TODO: Ștergere operatie
                                    },
                                  ),
                                ],
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
