import 'dart:convert';

import 'package:lambo01_master/models/app_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AppDataService {
  final String dataUrl = "https://raw.githubusercontent.com/fshangala/lambo01_master/refs/heads/main/data/lambo01.json";
  final String scriptUrl = "https://raw.githubusercontent.com/fshangala/lambo01_master/refs/heads/main/data/script.js";

  Future<AppDataModel> fetchAppData() async {
    String scriptSource = await fetchScript();
    final response = await http.get(Uri.parse(dataUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> appDataMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AppDataModel.fromJson({...appDataMap, 'script_source': scriptSource});
    } else {
      Logger().e('Failed to load app data: ${response.statusCode}', error: response.body);
      throw Exception('Failed to load app data: ${response.statusCode}');
    }
  }

  Future<String> fetchScript() async {
    final response = await http.get(Uri.parse(scriptUrl));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      Logger().e('Failed to load script: ${response.statusCode}', error: response.body);
      throw Exception('Failed to load script: ${response.statusCode}');
    }
  }
}