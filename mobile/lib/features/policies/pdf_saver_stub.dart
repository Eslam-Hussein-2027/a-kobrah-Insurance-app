import 'dart:typed_data';

const bool canSavePdf = false;

Future<void> saveAndOpenPdf(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Saving files is only supported on mobile.');
}
