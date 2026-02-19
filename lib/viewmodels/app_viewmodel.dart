import 'package:flutter/material.dart';
import 'package:lambo01_master/models/site_model.dart';
import 'package:lambo01_master/services/app_data_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppViewmodel extends ChangeNotifier {
  WebSocketChannel? channel;
  Exception? connectionError;

  final List<SiteModel> _websites = [];
  List<SiteModel> get websites => _websites;

  SiteModel? _currentWebsite;
  SiteModel? get currentWebsite => _currentWebsite;
  void setCurrentWebsite(SiteModel website) {
    _currentWebsite = website;
    notifyListeners();
  }

  Future<void> loadAppData() async {
    final appDataService = AppDataService();
    try {
      final appData = await appDataService.fetchAppData();
      _websites.clear();
      _websites.addAll(appData.sites);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger().e("Failed to load app data", error: e, stackTrace: stackTrace);
    }
  }

  void loadSettings() async{
    final prefs = await SharedPreferences.getInstance();
    final serverAddress = prefs.getString('server_address') ?? '';
    final serverPort = prefs.getString('server_port') ?? '';
    final roomCode = prefs.getString('room_code') ?? '';
    
    if(serverAddress.isNotEmpty && serverPort.isNotEmpty && roomCode.isNotEmpty) {
      connectToWebSocket(serverAddress, serverPort, roomCode);
    }
  }
  
  void connectToWebSocket(String serverAddress, String serverPort, String roomCode) async {
    connectionError = null;
    notifyListeners();
    
    final url = 'ws://$serverAddress:$serverPort/ws/pcautomation/$roomCode/';
    
    if (channel != null) {
      channel!.sink.close();
    }

    channel = WebSocketChannel.connect(Uri.parse(url));
    
    try {
      await channel?.ready;
    } on Exception catch (e, stackTrace) {
      connectionError = e;
      notifyListeners();
      Logger().e("Failed to connect to WebSocket", error: e, stackTrace: stackTrace);
    }
  }
  
}