import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../repositories/app_repo.dart';
import '../services/calculator.dart';
import '../services/location_service.dart';

class WorkEntryScreen extends StatefulWidget {
  final int? editId;
  const WorkEntryScreen({super.key, this.editId});

  @override
  State<WorkEntryScreen> createState() => _WorkEntryScreenState();
}

class _WorkEntryScreenState extends State<WorkEntryScreen> {
  final repo = AppRepo();
  final date = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final rate = TextEditingController(text: '0');
  final notes = TextEditingController();
  int? cat, customer;
  String type = 'Per Hour';
  String status = 'Paid';
  TimeOfDay? start, end;
  Map<String, double> calc = {'minutes': 0, 'hours': 0, 'amount': 0};
  List<XFile> attachments = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) _loadEdit();
  }

  void _loadEdit() async {
    final rows = await repo.query('SELECT * FROM work_entries WHERE id=?', [widget.editId]);
    if (rows.isNotEmpty) {
      final r = rows.first;
      setState(() {
        date.text = '${r['date']}';
        cat = r['category_id'] as int?;
        customer = r['customer_id'] as int?;
        type = '${r['payment_type']}';
        rate.text = '${r['rate']}';
        status = '${r['status']}';
        notes.text = '${r['notes'] ?? ''}';
      });
      recalc();
    }
  }

  int mins(TimeOfDay t) => t.hour * 60 + t.minute;

  void recalc() {
    if (start == null || end == null) return;
    setState(() {
      calc = BillingCalculator.calculate(
        type: type,
        rate: double.tryParse(rate.text) ?? 0.0,
        start: mins(start!),
        end: mins(end!),
      );
    });
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (d != null) date.text = DateFormat('yyyy-MM-dd').format(d);
  }

  Future<void> pickTime(bool isStart) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      setState(() {
        if (isStart) start = t; else end = t;
      });
      recalc();
    }
  }

  String _duration(int m) => '${m ~/ 60}h ${m % 60}m';

  Widget _line(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(l), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))],
    ),
  );

  void save() async {
    if (cat == null || customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select category and customer')));
      return;
    }
    setState(() => loading = true);
    final data = {
      'date': date.text,
      'category_id': cat,
      'customer_id': customer,
      'payment_type': type,
      'rate': double.tryParse(rate.text) ?? 0.0,
      'start_time': start != null ? '${start!.hour}:${start!.minute}' : '',
      'end_time': end != null ? '${end!.hour}:${end!.minute}' : '',
      'total_minutes': calc['minutes']!.toInt(),
      'total_hours': calc['hours'],
      'amount': calc['amount'],
      'status': status,
      'notes': notes.text,
    };
    if (widget.editId == null) {
      await repo.insert('work_entries', data);
    } else {
      await repo.update('work_entries', data, 'id = ?', [widget.editId]);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry saved successfully')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editId == null ? 'New Work Entry' : 'Edit Work Entry')),
      body: FutureBuilder(
        future: Future.wait([repo.rows('categories'), repo.rows('customers')]),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final cats = s.data![0];
          final cus = s.data![1];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: date,
                readOnly: true,
                onTap: pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: cat,
                decoration: const InputDecoration(labelText: 'Work Category', border: OutlineInputBorder()),
                items: cats.map((x) => DropdownMenuItem(value: x['id'] as int, child: Text('${x['name']}'))).toList(),
                onChanged: (v) => setState(() => cat = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: customer,
                decoration: const InputDecoration(labelText: 'Customer / Employer', border: OutlineInputBorder()),
                items: cus.map((x) => DropdownMenuItem(value: x['id'] as int, child: Text('${x['name']}'))).toList(),
                onChanged: (v) => setState(() => customer = v),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Per Minute', label: Text('Minute')),
                  ButtonSegment(value: 'Per Hour', label: Text('Hour')),
                  ButtonSegment(value: 'Per Day', label: Text('Day')),
                ],
                selected: {type},
                onSelectionChanged: (v) {
                  setState(() => type = v.first);
                  recalc();
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rate,
                onChanged: (_) => recalc(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '$type Rate',
                  prefixText: '₹ ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pickTime(true),
                      icon: const Icon(Icons.login),
                      label: Text(start == null ? 'Start Time' : start!.format(c)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pickTime(false),
                      icon: const Icon(Icons.logout),
                      label: Text(end == null ? 'End Time' : end!.format(c)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _line('Total Minutes', '${calc['minutes']!.toInt()}'),
                      _line('Total Hours', '${calc['hours']!.toStringAsFixed(2)}'),
                      _line('Duration', _duration(calc['minutes']!.toInt())),
                      _line('Amount', '₹${calc['amount']!.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Payment Status', border: OutlineInputBorder()),
                items: ['Paid', 'Partial Paid', 'Unpaid'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                onChanged: (v) => setState(() => status = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final xs = await ImagePicker().pickMultiImage();
                  setState(() => attachments = xs);
                },
                icon: const Icon(Icons.attach_file),
                label: Text('Attachments (${attachments.length})'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final loc = await LocationService().capture();
                  if (loc != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GPS: ${loc['lat']}, ${loc['lng']}')));
                  }
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Capture GPS Location'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: loading ? null : save,
                icon: const Icon(Icons.save),
                label: Text(loading ? 'Saving...' : 'Save Entry'),
              ),
            ],
          );
        },
      ),
    );
  }
}
