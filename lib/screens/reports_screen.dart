import 'package:flutter/material.dart';
import '../repositories/app_repo.dart';
import '../services/export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final repo = AppRepo();
  String period = 'All';

  Future<List<Map<String, Object?>>> get data async {
    return repo.rows('work_entries', order: 'date DESC');
  }

  void export() async {
    final d = await data;
    await ExportService().exportCsv('work_report', d);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report exported to CSV')));
    }
  }

  Widget _v(String a, String b) => Column(
    children: [
      Text(b, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(a),
    ],
  );

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('गोस्वारा / Reports'),
        actions: [IconButton(onPressed: export, icon: const Icon(Icons.file_download))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: period,
            items: ['Today', 'Month', 'Year', 'All'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() => period = v!),
            decoration: const InputDecoration(labelText: 'Report Period', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, Object?>>>(
            future: data,
            builder: (c, s) {
              if (!s.hasData) return const Center(child: CircularProgressIndicator());
              final d = s.data!;
              double amt = 0, h = 0;
              for (final r in d) {
                amt += (r['amount'] as num?)?.toDouble() ?? 0;
                h += (r['total_hours'] as num?)?.toDouble() ?? 0;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _v('Entries', d.length.toString()),
                          _v('Hours', h.toStringAsFixed(2)),
                          _v('Earnings', '₹${amt.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...d.map(
                    (r) => ListTile(
                      title: Text('${r['date']} • ${r['payment_type']}'),
                      subtitle: Text('${r['total_minutes']} min • ${r['status']}'),
                      trailing: Text('₹${((r['amount'] as num?) ?? 0).toStringAsFixed(2)}'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
