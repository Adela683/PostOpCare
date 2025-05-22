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
  List<int> _intervals = [];
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

  // Încarcă template-urile din Firestore
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

  // Adăugarea unui nou template cu intervale
  void _addTemplate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Surgery Template'),
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
                    if (newValue != null && !_selectedIntervals.contains(newValue)) {
                      setState(() {
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
                  decoration: InputDecoration(labelText: 'Add custom interval (weeks)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newInterval = int.tryParse(_newIntervalController.text);
                    if (newInterval != null && !_selectedIntervals.contains(newInterval)) {
                      setState(() {
                        _selectedIntervals.add(newInterval);
                      });
                      _newIntervalController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid or duplicate interval')),
                      );
                    }
                  },
                  child: Text('Add Custom Interval'),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: _selectedIntervals.map((interval) {
                    return Chip(
                      label: Text('$interval week(s)'),
                      deleteIcon: Icon(Icons.clear),
                      onDeleted: () {
                        setState(() {
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
                  final newTemplate = SurgeryTemplate(
                    id: '',
                    name: name,
                    intervals: _selectedIntervals,
                  );
                  _templateRepo.addTemplate(newTemplate).then((_) {
                    _loadTemplates();
                    Navigator.of(context).pop();
                  }).catchError((e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surgery Templates'),
        backgroundColor: const Color.fromARGB(255, 10, 221, 221),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addTemplate),
        ],
      ),
      body: _templates.isEmpty
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
    );
  }

  String _formatIntervals(List<int> intervals) {
    return intervals
        .map((interval) => interval == 1
            ? '$interval week'
            : '$interval weeks')
        .join(', ');
  }

  // Vizualizarea unui template și opțiunea de a-l edita
  void _viewTemplate(SurgeryTemplate template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(
          text: template.name,
        );
        TextEditingController intervalsController = TextEditingController(
          text: template.intervals.join(','),
        );

        return AlertDialog(
          title: Text(template.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Intervals: ${template.intervals.join(', ')} week'),
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
                final updatedName = nameController.text;
                final updatedIntervals =
                    intervalsController.text.split(',').map((e) => int.parse(e.trim())).toList();

                if (updatedName.isNotEmpty && updatedIntervals.isNotEmpty) {
                  final updatedTemplate = SurgeryTemplate(
                    id: template.id,
                    name: updatedName,
                    intervals: updatedIntervals,
                  );
                  _templateRepo.updateTemplate(updatedTemplate).then((_) {
                    _loadTemplates();
                    Navigator.of(context).pop();
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating template: $e')),
                    );
                  });
                }
              },
              child: Text('Save'),
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
}
