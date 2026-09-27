import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/app_repo.dart';
import 'master_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = AppRepo();
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    return _Dashboard(
      key: ValueKey(_refreshKey),
      repo: repo,
      refresh: _refresh,
      toggle: widget.toggleTheme,
    );
  }
}

class DashboardStats {
  final double income, expenses, outstanding, today, todayHours;
  DashboardStats(this.income, this.expenses, this.outstanding, this.today, this.todayHours);
}

Future<DashboardStats> fetchDashboardStats(AppRepo r) async {
  final a = await r.query('SELECT COALESCE(SUM(amount),0) as i, COALESCE(SUM(total_hours),0) as h FROM work_entries');
  final b = await r.query('SELECT COALESCE(SUM(amount),0) as e FROM expenses');
  final o = await r.query("SELECT COALESCE(SUM(amount),0) as x FROM work_entries WHERE status!='Paid'");
  final t = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final z = await r.query('SELECT COALESCE(SUM(amount),0) as i, COALESCE(SUM(total_hours),0) as h FROM work_entries WHERE date=?', [t]);
  return DashboardStats(
    (a[0]['i'] as num).toDouble(),
    (b[0]['e'] as num).toDouble(),
    (o[0]['x'] as num).toDouble(),
    (z[0]['i'] as num).toDouble(),
    (z[0]['h'] as num).toDouble(),
  );
}

class _Dashboard extends StatelessWidget {
  final AppRepo repo;
  final VoidCallback refresh, toggle;
  const _Dashboard({super.key, required this.repo, required this.refresh, required this.toggle});

  Widget _mini(String label, dynamic val) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('$val', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );

  Widget _card(String title, double val) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(title.contains('Hours') ? val.toStringAsFixed(2) : '₹${val.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext c) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Work Time & Billing Manager',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: toggle, icon: const Icon(Icons.dark_mode_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: Future.wait([
                repo.query('SELECT COUNT(*) as c FROM work_entries'),
                repo.query('SELECT COUNT(*) as c FROM customers'),
                repo.query('SELECT COUNT(*) as c FROM categories'),
              ]),
              builder: (c, s) {
                if (!s.hasData) return const LinearProgressIndicator();
                final d = s.data!;
                return Row(
                  children: [
                    _mini('Records', d[0].first['c']),
                    _mini('Customers', d[1].first['c']),
                    _mini('Categories', d[2].first['c']),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<DashboardStats>(
              future: fetchDashboardStats(repo),
              builder: (c, s) {
                if (!s.hasData) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                final x = s.data!;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _card('Today Earnings', x.today),
                    _card('Today Hours', x.todayHours),
                    _card('Total Earnings', x.income),
                    _card('Total Expenses', x.expenses),
                    _card('Net Profit', x.income - x.expenses),
                    _card('Outstanding', x.outstanding),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Work Categories'),
                  avatar: const Icon(Icons.category),
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => const MasterScreen(
                        title: 'Work Categories',
                        table: 'categories',
                        fields: ['name', 'description', 'rate_type', 'rate'],
                      ),
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Employees'),
                  avatar: const Icon(Icons.badge),
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => const MasterScreen(
                        title: 'Employees',
                        table: 'employees',
                        fields: ['name', 'mobile', 'address'],
                      ),
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Expenses'),
                  avatar: const Icon(Icons.money_off),
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => const MasterScreen(
                        title: 'Expenses',
                        table: 'expenses',
                        fields: ['date', 'category', 'amount', 'description', 'attachment'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
