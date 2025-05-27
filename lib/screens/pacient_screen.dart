import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/data/repositories/pacient_repository/pacient_repository.dart';
import 'package:postopcare/screens/pacient_details_screen.dart';
import '../route_observer.dart'; // importă observer-ul global

class PacientScreen extends StatefulWidget {
  final AppUser user;

  const PacientScreen({super.key, required this.user});

  @override
  State<PacientScreen> createState() => _PacientScreenState();
}

class _PacientScreenState extends State<PacientScreen> with RouteAware {
  late PatientRepository _patientRepo;
  late List<Pacient> _pacienti;
  late List<Pacient> _filteredPacienti;
  late TextEditingController _searchController;
  late TextEditingController _numeController;
  late TextEditingController _varstaController;
  late TextEditingController _telefonController;
  String? _selectedSex;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _patientRepo = PatientRepository(userId: widget.user.id!);
    _pacienti = [];
    _filteredPacienti = [];
    _searchController = TextEditingController();
    _numeController = TextEditingController();
    _varstaController = TextEditingController();
    _telefonController = TextEditingController();
    _loadPacienti();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredPacienti = _pacienti;
        } else {
          _filteredPacienti =
              _pacienti
                  .where((p) => p.nume.toLowerCase().startsWith(query))
                  .toList();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _numeController.dispose();
    _varstaController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  // Apelat când revii pe acest ecran (de ex după ce ai navigat în detalii)
  @override
  void didPopNext() {
    _loadPacienti();
  }

  Future<void> _loadPacienti() async {
    try {
      final pacients = await _patientRepo.getAllPacients();
      setState(() {
        _pacienti = pacients;
        _filteredPacienti = pacients;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la încărcarea pacienților: $e')),
        );
      }
    }
  }

  void _addPacientDialog() {
    _selectedSex = null;
    _telefonController.clear();
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
                    TextField(
                      controller: _telefonController,
                      decoration: InputDecoration(
                        labelText: 'Număr de telefon',
                        hintText: 'Ex: 0712345678',
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
                            return ChoiceChip(
                              label: Text(value),
                              selected: _selectedSex == value,
                              selectedColor: Colors.teal,
                              labelStyle: TextStyle(
                                color:
                                    _selectedSex == value
                                        ? Colors.white
                                        : Colors.black,
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
                final nume = _numeController.text.trim();
                final varsta = int.tryParse(_varstaController.text.trim()) ?? 0;
                final telefon = _telefonController.text.trim();

                if (nume.isNotEmpty &&
                    _selectedSex != null &&
                    varsta > 0 &&
                    telefon.length == 10) {
                  final newPacient = Pacient(
                    id: '',
                    nume: nume,
                    varsta: varsta,
                    sex: _selectedSex!,
                    telefon: telefon,
                  );
                  _patientRepo
                      .addPacient(newPacient)
                      .then((_) {
                        _loadPacienti();
                        Navigator.of(context).pop();
                        _numeController.clear();
                        _varstaController.clear();
                        _telefonController.clear();
                        _selectedSex = null;
                      })
                      .catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Eroare la adăugare: $e')),
                        );
                      });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Te rog completează toate câmpurile corect (telefon 10 cifre).',
                      ),
                    ),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            !_isSearching
                ? Text('Pacienți')
                : TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Caută pacient...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  autofocus: true,
                ),
        backgroundColor: const Color.fromARGB(255, 10, 221, 221),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _filteredPacienti = _pacienti;
                  _searchController.clear();
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          IconButton(icon: Icon(Icons.add), onPressed: _addPacientDialog),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/templates_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child:
            _pacienti.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount:
                      _isSearching
                          ? _filteredPacienti.length
                          : _pacienti.length,
                  itemBuilder: (context, index) {
                    final pacient =
                        _isSearching
                            ? _filteredPacienti[index]
                            : _pacienti[index];
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Vârstă: ${pacient.varsta}, Sex: ${pacient.sex}',
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => PacientDetailScreen(
                                      userId: widget.user.id!,
                                      pacient: pacient,
                                    ),
                              ),
                            );
                            print('Result from PacientDetailScreen: $result');
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
