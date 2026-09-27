import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();
  Database? _db;
  Future<Database> get db async => _db ??= await _open();
  Future<Database> _open() async {
    final p = join(await getDatabasesPath(), 'work_time_billing.db');
    return openDatabase(p, version: 1, onCreate: (db, v) async {
      await db.execute('''CREATE TABLE profiles(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,mobile TEXT,address TEXT,created_at TEXT)''');
      await db.execute('''CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,description TEXT,rate_type TEXT,rate REAL DEFAULT 0)''');
      await db.execute('''CREATE TABLE customers(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,mobile TEXT,address TEXT,village TEXT,notes TEXT)''');
      await db.execute('''CREATE TABLE work_entries(id INTEGER PRIMARY KEY AUTOINCREMENT,profile_id INTEGER DEFAULT 1,date TEXT NOT NULL,category_id INTEGER,customer_id INTEGER,payment_type TEXT NOT NULL,rate REAL NOT NULL,start_minute INTEGER,end_minute INTEGER,total_minutes INTEGER,total_hours REAL,total_days REAL,amount REAL,notes TEXT,lat REAL,lng REAL,address TEXT,status TEXT DEFAULT "Unpaid",created_at TEXT)''');
      await db.execute('''CREATE TABLE attachments(id INTEGER PRIMARY KEY AUTOINCREMENT,entry_id INTEGER,path TEXT,type TEXT)''');
      await db.execute('''CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT,profile_id INTEGER DEFAULT 1,date TEXT,category TEXT,amount REAL,description TEXT,attachment TEXT)''');
      await db.execute('''CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,mobile TEXT,address TEXT)''');
      await db.execute('''CREATE TABLE attendance(id INTEGER PRIMARY KEY AUTOINCREMENT,employee_id INTEGER,date TEXT,status TEXT,notes TEXT)''');
      await db.execute('''CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT,customer_id INTEGER,date TEXT,amount REAL,payment_mode TEXT,notes TEXT)''');
      await db.execute('''CREATE TABLE invoices(id INTEGER PRIMARY KEY AUTOINCREMENT,number TEXT,date TEXT,customer_id INTEGER,entry_ids TEXT,advance REAL,signature TEXT,status TEXT)''');
      await db.execute('''CREATE TABLE receipts(id INTEGER PRIMARY KEY AUTOINCREMENT,number TEXT,date TEXT,customer_id INTEGER,amount REAL,remaining REAL,payment_mode TEXT,signature TEXT)''');
      await db.execute('''CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT)''');
    });
  }
}
