import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lambo01_master/models/app_data_model.dart';
import 'package:lambo01_master/models/message_model.dart';
import 'package:lambo01_master/models/site_model.dart';
import 'package:lambo01_master/services/app_data_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppViewmodel extends ChangeNotifier {
  WebSocketChannel? channel;
  Exception? connectionError;

  AppDataModel? _appData;
  AppDataModel? get appData => _appData;

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
      Logger().d("script source loaded", error: appData.scriptSource);
      _appData = appData;
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

    final newChannel = WebSocketChannel.connect(Uri.parse(url));
    
    try {
      await newChannel.ready;
      channel = newChannel;
      notifyListeners();

    } on Exception catch (e, stackTrace) {
      connectionError = e;
      channel = null;
      notifyListeners();
      Logger().e("Failed to connect to WebSocket", error: e, stackTrace: stackTrace);
    }
  }

  Stream<MessageModel>? get messageStream {
    if (channel != null) {
      return channel!.stream.map((message) {
        try {
          final data = jsonDecode(message);
          return MessageModel.fromJson(data);
        } on Exception catch (e, stackTrace) {
          Logger().e("Failed to parse WebSocket message", error: e, stackTrace: stackTrace);
          return null;
        }
      }).where((message) => message != null).cast<MessageModel>();
    }
    return null;
  }

  void disconnectWebSocket() async {
    await channel?.sink.close();
    channel = null;
    connectionError = null;
    notifyListeners();
  }

  void sendMessage(MessageModel message) {
    if (channel != null) {
      try {
        final data = message.toMap();
        channel!.sink.add(jsonEncode(data));
        Logger().i("WebSocket message sent", error: message);
      } on Exception catch (e, stackTrace) {
        Logger().e("Failed to send WebSocket message", error: e, stackTrace: stackTrace);
      }
    } else {
      Logger().w("WebSocket is not connected. Message not sent.", error: message);
    }
  }
  
}