import 'dart:convert';
import 'dart:io';

class JsonGenerator {
  final String outputPath;

  JsonGenerator(this.outputPath);

  Future<void> generateJson(
    Map<String, Map<String, String>> translations,
  ) async {
    for (var language in translations.keys) {
      final file = File('$outputPath/$language.json');
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(translations[language]));
    }
  }
}
