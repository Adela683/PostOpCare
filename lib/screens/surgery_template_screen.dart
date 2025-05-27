import 'package:flutter/material.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/data/repositories/surgery_templates_repository/surgery_templates_repository.dart';

class SurgeryTemplateScreen extends StatefulWidget {
  final AppUser user;

  const SurgeryTemplateScreen({super.key, required this.user});

  @override
  State<SurgeryTemplateScreen> createState() => _SurgeryTemplateScreenState();
}

class _SurgeryTemplateScreenState extends State<SurgeryTemplateScreen> {
  late SurgeryTemplateRepository _templateRepo;
  late List<SurgeryTemplate> _templates;
  late TextEditingController _nameController;
  List<int> _selectedIntervals = [];
  late TextEditingController _newIntervalController;

  @override
  void initState() {
    super.initState();
    _templateRepo = SurgeryTemplateRepository(userId: widget.user.id!);
    _templates = [];
    _nameController = TextEditingController();
    _newIntervalController = TextEditingController();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _templateRepo.getAllTemplates();
      setState(() {
        _templates = templates;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading templates: $e')));
    }
  }

  void _addOrEditTemplate(SurgeryTemplate? template) {
    if (template != null) {
      _nameController.text = template.name;
      _selectedIntervals = List.from(template.intervals);
    } else {
      _nameController.clear();
      _selectedIntervals.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                template != null
                    ? 'Edit Surgery Template'
                    : 'Add Surgery Template',
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Template Name'),
                    ),
                    SizedBox(height: 20),
                    Text('Select Intervals:'),
                    DropdownButton<int>(
                      hint: Text('Select Interval'),
                      value: null,
                      onChanged: (int? newValue) {
                        if (newValue != null &&
                            !_selectedIntervals.contains(newValue)) {
                          setStateDialog(() {
                            _selectedIntervals.add(newValue);
                          });
                        }
                      },
                      items: List.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('${index + 1} week(s)'),
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _newIntervalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Add custom interval (weeks)',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final newInterval = int.tryParse(
                          _newIntervalController.text,
                        );
                        if (newInterval != null &&
                            !_selectedIntervals.contains(newInterval)) {
                          setStateDialog(() {
                            _selectedIntervals.add(newInterval);
                          });
                          _newIntervalController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invalid or duplicate interval'),
                            ),
                          );
                        }
                      },
                      child: Text('Add Custom Interval'),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      children:
                          _selectedIntervals.map((interval) {
                            return Chip(
                              label: Text('$interval week(s)'),
                              deleteIcon: Icon(Icons.clear),
                              onDeleted: () {
                                setStateDialog(() {
                                  _selectedIntervals.remove(interval);
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
                  onPressed: () {
                    final name = _nameController.text;
                    if (name.isNotEmpty && _selectedIntervals.isNotEmpty) {
                      _selectedIntervals.sort();

                      final newTemplate = SurgeryTemplate(
                        id: template?.id ?? '',
                        name: name,
                        intervals: _selectedIntervals,
                      );
                      if (template == null) {
                        _templateRepo
                            .addTemplate(newTemplate)
                            .then((_) {
                              _loadTemplates();
                              Navigator.of(context).pop();
                              _nameController.clear();
                              _newIntervalController.clear();
                              _selectedIntervals.clear();
                            })
                            .catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding template: $e'),
                                ),
                              );
                            });
                      } else {
                        _templateRepo
                            .updateTemplate(newTemplate)
                            .then((_) {
                              _loadTemplates();
                              Navigator.of(context).pop();
                            })
                            .catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating template: $e'),
                                ),
                              );
                            });
                      }
                    }
                  },
                  child: Text(template != null ? 'Save' : 'Add'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatIntervals(List<int> intervals) {
    return intervals
        .map((interval) => interval == 1 ? '$interval week' : '$interval weeks')
        .join(', ');
  }

  void _viewTemplate(SurgeryTemplate template) {
    _addOrEditTemplate(template);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surgery Templates'),
        backgroundColor: const Color.fromARGB(255, 10, 221, 221),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch<SurgeryTemplate?>(
                context: context,
                delegate: TemplateSearchDelegate(templates: _templates),
              );
              if (result != null) {
                _viewTemplate(result);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addOrEditTemplate(null),
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
        child:
            _templates.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white.withOpacity(0.8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            template.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Intervals: ${_formatIntervals(template.intervals)}',
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () => _viewTemplate(template),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class TemplateSearchDelegate extends SearchDelegate<SurgeryTemplate?> {
  final List<SurgeryTemplate> templates;

  TemplateSearchDelegate({required this.templates});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        templates
            .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        templates
            .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return _buildList(suggestions);
  }

  Widget _buildList(List<SurgeryTemplate> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final template = list[index];
        return ListTile(
          title: Text(template.name),
          onTap: () => close(context, template),
        );
      },
    );
  }
}
