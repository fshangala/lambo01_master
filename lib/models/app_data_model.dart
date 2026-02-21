import 'package:lambo01_master/models/site_model.dart';

class AppDataModel {
  String version;
  String scriptSource;
  List<SiteModel> sites;

  AppDataModel({
    required this.version,
    required this.scriptSource,
    required this.sites,
  });

  factory AppDataModel.fromJson(Map<String, dynamic> json) {
    return AppDataModel(
      version: json['version'] as String,
      scriptSource: json['script_source'] as String,
      sites: (json['sites'] as List<dynamic>)
          .map((siteJson) => SiteModel.fromJson(siteJson as Map<String, dynamic>))
          .toList(),
    );
  }
}