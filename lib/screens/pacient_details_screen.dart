import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postopcare/data/models/pacient.dart';
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

  @override
  void initState() {
    super.initState();
    _surgeryRepo = SurgeryRepository(userId: widget.userId, pacientId: widget.pacient.id);
    _loadSurgeries();
  }

  void _loadSurgeries() {
    setState(() {
      _surgeriesFuture = _surgeryRepo.getSurgeries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pacient = widget.pacient;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: edit pacient
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // TODO: delete pacient
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sectiune sus cu inaltime mai mare - fundal imagine + gradient + detalii pacient
          Container(
            height: 240, // inaltime crescuta pentru telefon
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
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 16), // padding ajustat jos
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
                  if (pacient.telefon != null && pacient.telefon!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            pacient.telefon!,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Sectiune jos - alb, colturi rotunjite sus, continut lista operatii
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
                  // Titlu + buton + intr-un rand
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

                  // Lista operatii
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
