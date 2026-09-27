import 'package:flutter/material.dart';
import '../repositories/app_repo.dart';

class MasterScreen extends StatefulWidget {
  final String title;
  final String table;
  final List<String> fields;
  const MasterScreen({super.key, required this.title, required this.table, required this.fields});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final repo = AppRepo();
  String q = '';

  Future<List<Map<String, Object?>>> get data async => repo.rows(widget.table, order: 'id DESC');

  String label(String f) => f.replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());

  void form([Map<String, Object?>? r]) {
    final controllers = {for (var f in widget.fields) f: TextEditingController(text: '${r?[f] ?? ''}')};
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r == null ? 'Add ${widget.title}' : 'Edit ${widget.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: controllers[f],
                decoration: InputDecoration(labelText: label(f), border: const OutlineInputBorder()),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final map = {for (var f in widget.fields) f: controllers[f]!.text};
              if (r == null) {
                await repo.insert(widget.table, map);
              } else {
                await repo.update(widget.table, map, r['id'] as int);
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: data,
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final list = s.data!;
          final filtered = list.where((r) => q.isEmpty || r.values.any((v) => '$v'.toLowerCase().contains(q.toLowerCase()))).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => q = v),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search', border: OutlineInputBorder()),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (c, i) {
                    final r = filtered[i];
                    final title = r[widget.fields.first] ?? r['id'];
                    return Card(
                      child: ListTile(
                        title: Text('$title'),
                        subtitle: Text(widget.fields.skip(1).take(3).map((f) => '${label(f)}: ${r[f] ?? ''}').join(' • ')),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'e', child: Text('Edit')),
                            PopupMenuItem(value: 'd', child: Text('Delete')),
                          ],
                          onSelected: (v) async {
                            if (v == 'e') {
                              form(r);
                            } else {
                              await repo.delete(widget.table, r['id'] as int);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => form(), child: const Icon(Icons.add)),
    );
  }
}
