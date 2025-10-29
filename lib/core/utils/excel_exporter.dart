import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExporter {
  static Future<File?> exportToExcel(List data) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() ?? 'Sheet1'];

    if (sheet == null) return null;

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'Timestamp',
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Temperature',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Humidity');

    for (int i = 0; i < data.length; i++) {
      final row = i + 2;
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        data[i].timestamp.toString(),
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = data[i].temperature;
      sheet.cell(CellIndex.indexByString('C$row')).value = data[i].humidity;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sensor_data.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
}
