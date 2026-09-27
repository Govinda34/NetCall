import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class WorkTimeApp extends StatefulWidget {
  const WorkTimeApp({super.key});
  @override State<WorkTimeApp> createState() => _WorkTimeAppState();
}
class _WorkTimeAppState extends State<WorkTimeApp> {
  ThemeMode mode = ThemeMode.system;
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Work Time & Billing Manager', debugShowCheckedModeBanner: false,
    themeMode: mode,
    theme: ThemeData(useMaterial3:true, colorSchemeSeed:Colors.indigo, brightness:Brightness.light),
    darkTheme: ThemeData(useMaterial3:true, colorSchemeSeed:Colors.indigo, brightness:Brightness.dark),
    home: HomeScreen(onToggleTheme: () => setState(() => mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark)),
  );
}
