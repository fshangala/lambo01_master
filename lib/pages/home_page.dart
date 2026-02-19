import 'package:flutter/material.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lambo01 Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(future: appViewmodel.loadAppData(), builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
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
            );
          }
        }),
      ),
    );
  }
}