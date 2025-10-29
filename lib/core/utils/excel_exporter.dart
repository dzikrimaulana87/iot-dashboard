import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExporter {
  static Future<File?> exportToExcel(List data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'Timestamp',
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Temperature',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Humidity');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
      'Status Temperature',
    );
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue(
      'Status Humidity',
    );

    // Isi data
    print("=== Isi data yang akan diekspor ===");
    for (var item in data) {
      print('Timestamp: ${item.timestamp}');
      print('Temperature: ${item.temperature}');
      print('Humidity: ${item.humidity}');
      print('Status Temperature: ${item.statusTemperature}');
      print('Status Humidity: ${item.statusHumidity}');
      print('--------------------------');
    }

    for (int i = 0; i < data.length; i++) {
      final row = i + 2;
      final item = data[i];

      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        item.timestamp.toString(),
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = DoubleCellValue(
        item.temperature.toDouble(),
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = DoubleCellValue(
        item.humidity.toDouble(),
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        item.statusTemperature.toString(),
      );
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(
        item.statusHumidity.toString(),
      );
    }

    // Tentukan folder tujuan
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isWindows) {
      final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
      downloadsDir = Directory(downloadsPath);
    } else if (Platform.isMacOS) {
      downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    // Pastikan folder ada
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    // 🔹 Tambahkan timestamp unik agar file tidak bertabrakan
    final now = DateTime.now();
    final timestamp =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    final filename = 'sensor_data_$timestamp.xlsx';

    final path = '${downloadsDir.path}/$filename';
    final fileBytes = excel.encode();
    if (fileBytes == null) return null;

    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);

    print('✅ File berhasil disimpan di: $path');
    return file;
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
