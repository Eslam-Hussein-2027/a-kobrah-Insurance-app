import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

const bool canSavePdf = true;

/// Writes the PDF to the app documents folder and opens it in the system viewer,
/// from where the customer can print or share it.
Future<void> saveAndOpenPdf(Uint8List bytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(file.path, type: 'application/pdf');
}
