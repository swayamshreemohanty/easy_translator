import 'dart:io';

class StringExtractor {
  final String projectPath;

  StringExtractor(this.projectPath);

  final String translationSuffix = '.translate()';

  Future<List<String>> extractStrings() async {
    final List<String> extractedStrings = [];
    final dir = Directory(projectPath);

    await for (var entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final matches = RegExp(r'"(.*?)"' + RegExp.escape(translationSuffix)).allMatches(content);
        for (var match in matches) {
          extractedStrings.add(match.group(1)!);
        }
      }
    }

    return extractedStrings;
  }
}
