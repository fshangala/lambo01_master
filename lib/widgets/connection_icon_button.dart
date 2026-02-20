import 'package:flutter/material.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';

class ConnectionIconButton extends StatelessWidget {
  const ConnectionIconButton({super.key});


  @override
  Widget build(BuildContext context) {
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: true);

    if (appViewmodel.channel != null) {
      return FutureBuilder(
        future: appViewmodel.channel!.ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return IconButton(
              onPressed: () {
                appViewmodel.disconnectWebSocket();
              }, 
              icon: Icon(
                Icons.error, 
                color: Colors.red,
              )
            );
          } else {
            return IconButton(
              onPressed: () {
                appViewmodel.disconnectWebSocket();
              }, 
              icon: Icon(
                Icons.stop, 
                color: Colors.red,
              )
            );
          }
        },
      );
    } else {
      return IconButton(
        onPressed: (){
          appViewmodel.loadSettings();
        },
        icon: Icon(
          Icons.play_arrow, 
          color: Colors.green,
        )
      );
    }
  }
}