import 'dart:convert';

import 'package:http/http.dart' as http;

class GoogleSheetService {
  final String sheetUrl;
  final String spreadsheetId;
  final String sheetName;

  GoogleSheetService({
    required this.sheetUrl,
    required this.spreadsheetId,
    required this.sheetName,
  });

  Future<List<Map<String, dynamic>>> fetchTranslations() async {
    try {
      // Prepare the GET request URL
      final url = Uri.parse(
        '$sheetUrl?spreadsheetId=$spreadsheetId&sheetName=$sheetName&all=true',
      );

      // Send the GET request
      final response = await http.get(url);

      // Validate the response
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch translations: ${response.body}');
      }

      // Parse the response body
      final data = jsonDecode(response.body);
      if (data['status'] != 'SUCCESS') {
        throw Exception('Error from Google Sheet: ${data['message']}');
      }

      // Extract and parse rows from the response
      return _parseSheetData(data['data']);
    } catch (e) {
      print('Error while fetching translations: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _parseSheetData(dynamic rawData) {
    final rows = List<List<dynamic>>.from(rawData);
    if (rows.isEmpty) return []; // Return an empty list if no data is present

    // Use the first row as headers and map subsequent rows to key-value pairs
    final headers = rows.first.map((header) => header.toString()).toList();
    return rows
        .skip(1) // Skip the header row
        .map(
          (row) => Map<String, dynamic>.fromIterables(
            headers,
            row.map(
              (value) => value ?? '',
            ), // Default empty cells to an empty string
          ),
        )
        .toList();
  }

  Future<void> pushStrings(List<String> strings) async {
    try {
      // Prepare the request body
      final body = {
        'spreadsheetId': spreadsheetId,
        'sheetName': sheetName,
        'values': jsonEncode(
          strings.map((s) => [s]).toList(),
        ), // Properly encode as JSON
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(sheetUrl),
        body: body,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      // Handle redirects (302)
      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];

        if (redirectUrl != null) {
          // Send a GET request to the redirect URL
          final redirectResponse = await http.get(
            Uri.parse(redirectUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          );

          if (redirectResponse.statusCode != 200) {
            throw Exception(
              'Failed to push strings to Google Sheet after redirect: ${redirectResponse.body}',
            );
          }

          print(
            'Strings pushed successfully after redirect: ${redirectResponse.body}',
          );
          return;
        }
      }

      // Check the response for the initial POST request
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to push strings to Google Sheet: ${response.body}',
        );
      }

      print('Strings pushed successfully: ${response.body}');
    } catch (e) {
      print('An error occurred while pushing strings: $e');
      rethrow;
    }
  }
}
