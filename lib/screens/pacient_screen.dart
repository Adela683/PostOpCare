import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/data/repositories/pacient_repository.dart';

class PacientScreen extends StatefulWidget {
  final AppUser user;

  const PacientScreen({super.key, required this.user});

  @override
  State<PacientScreen> createState() => _PacientScreenState();
}

class _PacientScreenState extends State<PacientScreen> {
  late PatientRepository _patientRepo;
  late List<Pacient> _pacienti;
  late TextEditingController _numeController;
  late TextEditingController _varstaController;
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    _patientRepo = PatientRepository(userId: widget.user.id!);
    _pacienti = [];
    _numeController = TextEditingController();
    _varstaController = TextEditingController();
    _loadPacienti();
  }

  Future<void> _loadPacienti() async {
    try {
      final pacients = await _patientRepo.getAllPacients();
      setState(() {
        _pacienti = pacients;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea pacienților: $e')),
      );
    }
  }

  void _addPacientDialog() {
    _selectedSex = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adaugă pacient'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
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
                            setStateDialog(() {
                              _selectedSex = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                final nume = _numeController.text;
                final varsta = int.tryParse(_varstaController.text) ?? 0;

                if (nume.isNotEmpty && _selectedSex != null && varsta > 0) {
                  final newPacient = Pacient(
                    id: '',
                    nume: nume,
                    varsta: varsta,
                    sex: _selectedSex!,
                  );
                  _patientRepo.addPacient(newPacient).then((_) {
                    _loadPacienti();
                    Navigator.of(context).pop();
                    _numeController.clear();
                    _varstaController.clear();
                    _selectedSex = null;
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Eroare la adăugare: $e')),
                    );
                  });
                }
              },
              child: Text('Adaugă'),
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

  void _viewPacientDialog(Pacient pacient) {
    TextEditingController numeCtrl = TextEditingController(text: pacient.nume);
    TextEditingController varstaCtrl = TextEditingController(text: pacient.varsta.toString());
    String selectedSex = pacient.sex;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editează pacient'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: numeCtrl, decoration: InputDecoration(labelText: 'Nume')),
                  TextField(
                    controller: varstaCtrl,
                    decoration: InputDecoration(labelText: 'Vârstă'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 10),
                  Text('Sex:'),
                  Wrap(
                    spacing: 10,
                    children: ['M', 'F'].map((value) {
                      return ChoiceChip(
                        label: Text(value),
                        selected: selectedSex == value,
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: selectedSex == value ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setStateDialog(() {
                            selectedSex = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedPacient = Pacient(
                  id: pacient.id,
                  nume: numeCtrl.text,
                  varsta: int.tryParse(varstaCtrl.text) ?? pacient.varsta,
                  sex: selectedSex,
                );
                _patientRepo.updatePacient(updatedPacient).then((_) {
                  _loadPacienti();
                  Navigator.of(context).pop();
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Eroare la salvare: $e')),
                  );
                });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacienți'),
        backgroundColor: const Color.fromARGB(255, 10, 221, 221),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addPacientDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/templates_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _pacienti.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _pacienti.length,
                itemBuilder: (context, index) {
                  final pacient = _pacienti[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          pacient.nume,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Vârstă: ${pacient.varsta}, Sex: ${pacient.sex}',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () => _viewPacientDialog(pacient),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _patientRepo.deletePacient(pacient.id).then((_) => _loadPacienti());
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
