import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<File> csvFile(String name,List<List<Object?>> rows) async { final dir=await getTemporaryDirectory(); final f=File('${dir.path}/$name.csv'); await f.writeAsString(const ListToCsvConverter().convert(rows)); return f; }
  Future<File> pdfFile(String name,String title,List<List<String>> rows) async { final doc=pw.Document(); doc.addPage(pw.MultiPage(build:(_)=>[pw.Text(title,style:pw.TextStyle(fontSize:20)),pw.SizedBox(height:12),pw.Table.fromTextArray(data:rows)])); final dir=await getTemporaryDirectory(); final f=File('${dir.path}/$name.pdf'); await f.writeAsBytes(await doc.save()); return f; }
  Future<void> share(File file) async => Share.shareXFiles([XFile(file.path)]);
}
