import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecManager {
  final String projectPath;

  PubspecManager(this.projectPath);

  Future<Map<String, dynamic>> readEasyTranslatorConfig() async {
    final pubspecFile = File('$projectPath/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found in the project directory.');
    }

    final content = await pubspecFile.readAsString();
    final yamlMap = loadYaml(content);

    if (yamlMap['easy_translator'] == null) {
      throw Exception(
        'easy_translator configuration not found in pubspec.yaml.',
      );
    }

    final config = yamlMap['easy_translator'] as YamlMap;

    return {
      'path': config['path'] as String?,
      'output_path': config['output_path'] as String?,
      'sheet_url': config['sheet_url'] as String?,
      'sheet_name': config['sheet_name'] as String?,
      'sheet_id': config['sheet_id'] as String?,
    };
  }

  Future<void> addAssetsPath(String assetsPath) async {
    final pubspecFile = File('$projectPath/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found in the project directory.');
    }

    final content = await pubspecFile.readAsString();
    final yamlEditor = YamlEditor(content);

    try {
      final yamlMap = loadYaml(content);

      // Check if `flutter` key exists
      if (yamlMap['flutter'] == null) {
        yamlEditor.update(
          ['flutter'],
          {
            'assets': [assetsPath],
          },
        );
      } else {
        final flutterSection = yamlMap['flutter'] as YamlMap;

        // Check if `assets` key exists
        if (flutterSection['assets'] == null) {
          yamlEditor.update(['flutter', 'assets'], [assetsPath]);
        } else {
          final assetsList = List<String>.from(flutterSection['assets']);
          if (!assetsList.contains(assetsPath)) {
            assetsList.add(assetsPath);
            yamlEditor.update(['flutter', 'assets'], assetsList);
          }
        }
      }

      // Write the updated YAML back to the file
      await pubspecFile.writeAsString(yamlEditor.toString());
      print('Assets path added successfully to pubspec.yaml.');
    } catch (e) {
      throw Exception('Failed to update pubspec.yaml: $e');
    }
  }
}
