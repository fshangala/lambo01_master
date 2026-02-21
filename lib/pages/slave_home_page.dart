import 'package:flutter/material.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:lambo01_master/widgets/connection_icon_button.dart';
import 'package:provider/provider.dart';

class SlaveHomePage extends StatefulWidget {
  const SlaveHomePage({super.key});

  @override
  State<SlaveHomePage> createState() => _SlaveHomePageState();
}

class _SlaveHomePageState extends State<SlaveHomePage> {

  @override
  void initState() {
    super.initState();
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: false);
    appViewmodel.loadAppData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slave Home'),
        actions: [
          ConnectionIconButton(),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome, Slave!'),
      ),
    );
  }
}