import 'package:flutter/material.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:lambo01_master/widgets/connection_icon_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: false);
    appViewmodel.loadAppData();
  }

  @override
  Widget build(BuildContext context) {
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await appViewmodel.loadAppData();
          },
          child: ListView.builder(
            itemCount: appViewmodel.websites.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(appViewmodel.websites[index].name),
                subtitle: Text(appViewmodel.websites[index].url),
                onTap: () {
                  appViewmodel.setCurrentWebsite( appViewmodel.websites[index] );
                  Navigator.pushNamed(context, '/browser');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}