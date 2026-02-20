import 'dart:convert';

import 'package:lambo01_master/models/app_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AppDataService {
  final String dataUrl = "https://raw.githubusercontent.com/fshangala/lambo01_master/refs/heads/main/data/lambo01.json";

  Future<AppDataModel> fetchAppData() async {
    final response = await http.get(Uri.parse(dataUrl));
    if (response.statusCode == 200) {
      return AppDataModel.fromJson(jsonDecode(response.body));
    } else {
      Logger().e('Failed to load app data: ${response.statusCode}', error: response.body);
      throw Exception('Failed to load app data: ${response.statusCode}');
    }
  }
}