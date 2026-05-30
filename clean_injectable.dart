// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('injectable')) {
      // Remove import
      content = content.replaceAll(
          RegExp(r"import 'package:injectable/injectable\.dart';\n"), '');

      // Remove annotations
      content = content.replaceAll('@injectable\n', '');
      content = content.replaceAll('@lazySingleton\n', '');
      content =
          content.replaceAll(RegExp(r'@LazySingleton\(as: [a-zA-Z_]+\)\n'), '');
      content = content.replaceAll('@LazySingleton()\n', '');

      file.writeAsStringSync(content);
      print('Cleaned ${file.path}');
    }
  }
}
