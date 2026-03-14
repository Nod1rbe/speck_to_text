import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<File?> pickFile({required FileType type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
}