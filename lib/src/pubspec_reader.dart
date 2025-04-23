import 'dart:io';
import 'package:yaml/yaml.dart';

class PubspecReader {
  final String projectPath;

  PubspecReader(this.projectPath);

  Future<Map<String, dynamic>> readEasyTranslatorConfig() async {
    final pubspecFile = File('$projectPath/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found in the project directory.');
    }

    final content = await pubspecFile.readAsString();
    final yamlMap = loadYaml(content);

    if (yamlMap['easy_translator'] == null) {
      throw Exception('easy_translator configuration not found in pubspec.yaml.');
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
}