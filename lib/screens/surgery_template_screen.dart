import 'package:flutter/material.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/data/repositories/surgery_templates_repository/surgery_templates_repository.dart'; // Importul repository-ului

class SurgeryTemplateScreen extends StatefulWidget {
  final AppUser user; // Folosim obiectul complet 'user'

  const SurgeryTemplateScreen({
    super.key,
    required this.user,
  }); // Primim obiectul complet 'user'

  @override
  State<SurgeryTemplateScreen> createState() => _SurgeryTemplateScreenState();
}

class _SurgeryTemplateScreenState extends State<SurgeryTemplateScreen> {
  late SurgeryTemplateRepository _templateRepo;
  late List<SurgeryTemplate> _templates;
  List<SurgeryTemplate> _filteredTemplates = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _templateRepo = SurgeryTemplateRepository(
      userId: widget.user.id!,
    ); // Folosim 'widget.user.id'
    _templates = [];
    _filteredTemplates = [];
    _searchController = TextEditingController();
    _loadTemplates();

    // Ascultă modificările în TextEditingController
    _searchController.addListener(_filterTemplates);
  }

  // Încarcă template-urile din Firestore
  Future<void> _loadTemplates() async {
    try {
      final templates = await _templateRepo.getAllTemplates();
      setState(() {
        _templates = templates;
        _filteredTemplates = templates;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading templates: $e')));
    }
  }

  // Filtrarea template-urilor pe baza textului introdus
  void _filterTemplates() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTemplates =
          _templates
              .where((template) => template.name.toLowerCase().contains(query))
              .toList();
    });
  }

  // Adăugarea unui nou template
  void _addTemplate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController intervalsController = TextEditingController();

        return AlertDialog(
          title: Text('Add Surgery Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Template Name'),
              ),
              TextField(
                controller: intervalsController,
                decoration: InputDecoration(
                  labelText: 'Intervals (comma separated)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final intervals =
                    intervalsController.text
                        .split(',')
                        .map((e) => int.parse(e.trim()))
                        .toList();

                if (name.isNotEmpty && intervals.isNotEmpty) {
                  final newTemplate = SurgeryTemplate(
                    id: '', // id-ul va fi generat de Firestore
                    name: name,
                    intervals: intervals,
                  );

                  _templateRepo
                      .addTemplate(newTemplate)
                      .then((_) {
                        // Încarcă din nou template-urile
                        _loadTemplates();
                        Navigator.of(context).pop();
                      })
                      .catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding template: $e')),
                        );
                      });
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Afișarea unui template cu intervalele sale
  void _viewTemplate(SurgeryTemplate template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(template.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Intervals: ${template.intervals.join(', ')} weeks.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
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
        title: Text('Surgery Templates'),
        backgroundColor: const Color.fromARGB(255, 17, 213, 213),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTemplate, // Adaugă un template nou
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Focus pe TextField de căutare
              showSearch(
                context: context,
                delegate: _SearchDelegate(templates: _filteredTemplates),
              );
            },
          ),
        ],
      ),
      body:
          _filteredTemplates.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading
              : ListView.builder(
                itemCount: _filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = _filteredTemplates[index];
                  return ListTile(
                    title: Text(template.name),
                    subtitle: Text(
                      'Intervals: ${template.intervals.join(', ')}',
                    ),
                    onTap:
                        () => _viewTemplate(template), // Vizualizare template
                  );
                },
              ),
    );
  }
}

class _SearchDelegate extends SearchDelegate {
  final List<SurgeryTemplate> templates;

  _SearchDelegate({required this.templates});

  @override
  Widget buildSuggestions(BuildContext context) {
    // Căutare în timp real pe măsură ce utilizatorul tastează
    final suggestions =
        query.isEmpty
            ? templates
            : templates
                .where(
                  (template) =>
                      template.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final template = suggestions[index];
        return ListTile(
          title: Text(template.name),
          subtitle: Text('Intervals: ${template.intervals.join(', ')}'),
          onTap: () {
            // Afișează template-ul ales
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _viewTemplateScreen(template),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Căutare finală care arată rezultatele
    final results =
        query.isEmpty
            ? templates
            : templates
                .where(
                  (template) =>
                      template.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final template = results[index];
        return ListTile(
          title: Text(template.name),
          subtitle: Text('Intervals: ${template.intervals.join(', ')}'),
          onTap: () {
            // Afișează template-ul ales
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _viewTemplateScreen(template),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Butonul pentru a închide căutarea (butonul de back)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Buton pentru a șterge textul introdus în câmpul de căutare
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Resetează câmpul de căutare
        },
      ),
    ];
  }

  // Funcție pentru a vizualiza detalii despre template
  Widget _viewTemplateScreen(SurgeryTemplate template) {
    return Scaffold(
      appBar: AppBar(title: Text(template.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Intervals: ${template.intervals.join(', ')} weeks'),
            // Poți adăuga mai multe detalii despre template aici
          ],
        ),
      ),
    );
  }
}
