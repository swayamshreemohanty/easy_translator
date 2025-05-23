import 'dart:io';

import 'google_sheet_service.dart';
import 'json_generator.dart';
import 'pubspec_reader.dart';
import 'string_extractor.dart';

class CommandRunner {
  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      print('Please provide a command: extract, push, fetch');
      return;
    }

    // Get the current working directory (assumes the package is run from the Flutter project root)
    final projectPath = Directory.current.path;

    // Read the configuration from pubspec.yaml
    final pubspecManager = PubspecManager(projectPath);
    final config = await pubspecManager.readEasyTranslatorConfig();

    final sourcePath = config['path'] ?? 'lib';
    final outputPath = config['output_path'] ?? 'assets/language';
    final sheetUrl = config['sheet_url'];
    final sheetName = config['sheet_name'];
    final sheetId = config['sheet_id'];

    if (sheetUrl == null || sheetName == null || sheetId == null) {
      print('Missing required Google Sheet configuration in pubspec.yaml.');
      return;
    }

    final command = arguments[0];
    switch (command) {
      case 'push':
        final extractor = StringExtractor('$projectPath/$sourcePath');
        final strings = await extractor.extractStrings(); // Extract strings
        if (strings.isEmpty) {
          print('No strings found to push.');
          return;
        }
        final service = GoogleSheetService(
          sheetUrl: sheetUrl,
          spreadsheetId: sheetId,
          sheetName: sheetName,
        );
        await service.pushStrings(strings); // Push extracted strings

        //Click the link to open the Google Sheet in the browser
        print(
          'Open the Google Sheet to start translating: https://docs.google.com/spreadsheets/d/$sheetId',
        );
        break;

      case 'fetch':
        try {
          final generator = JsonGenerator('$projectPath/$outputPath');
          final service = GoogleSheetService(
            sheetUrl: sheetUrl,
            spreadsheetId: sheetId,
            sheetName: sheetName,
          );

          // Fetch translations as a list of maps
          final translationsRawData = await service.fetchTranslations();

          // Transform the fetched data into a Map<String, Map<String, String>>
          final translations = <String, Map<String, String>>{};

          for (final row in translationsRawData) {
            final key = row['key_string'] as String?;
            if (key == null || key.isEmpty) continue;

            row.forEach((languageCode, value) {
              if (languageCode != 'key_string') {
                translations.putIfAbsent(languageCode, () => {})[key] =
                    value as String? ?? '';
              }
            });
          }

          // Generate JSON files from fetched translations
          await generator.generateJson(translations);

          print('JSON files generated successfully.');

          // Add the assets path to pubspec.yaml
          await pubspecManager.addAssetsPath(
            outputPath.endsWith('/') ? outputPath : '$outputPath/',
          ); // Ensure the path ends with a slash
          print('Assets path added to pubspec.yaml.');
        } catch (e) {
          print('Error while fetching translations: $e');
        }
        break;

      default:
        print('Unknown command: $command');
    }
  }
}
