import 'package:flutter/material.dart';
import 'package:postopcare/data/models/pacient.dart';

class PacientSearchWidget extends StatefulWidget {
  final List<Pacient> pacients;
  final void Function(Pacient) onSelected;

  const PacientSearchWidget({
    super.key,
    required this.pacients,
    required this.onSelected,
  });

  @override
  State<PacientSearchWidget> createState() => _PacientSearchWidgetState();
}

class _PacientSearchWidgetState extends State<PacientSearchWidget> {
  late TextEditingController _controller;
  List<Pacient> _filteredPacients = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _filteredPacients = widget.pacients;
    _controller.addListener(_filterPacients);
  }

  void _filterPacients() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPacients = widget.pacients;
      } else {
        _filteredPacients =
            widget.pacients
                .where((p) => p.nume.toLowerCase().startsWith(query))
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_filterPacients);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Caută pacient...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredPacients.length,
            itemBuilder: (context, index) {
              final pacient = _filteredPacients[index];
              return ListTile(
                title: Text(pacient.nume),
                subtitle: Text(
                  'Vârstă: ${pacient.varsta}, Sex: ${pacient.sex}',
                ),
                onTap: () => widget.onSelected(pacient),
              );
            },
          ),
        ),
      ],
    );
  }
}
