import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> websites = [
    'https://www.lambo01.com',
    'https://www.lambo01.com/zh-cn',
    'https://www.lambo01.com/zh-tw',
  ];

  @override
  Widget build(BuildContext context) {
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
        child: ListView.builder(
          itemCount: websites.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(websites[index]),
              onTap: () {
                // Handle website tap
                print('Tapped website: ${websites[index]}');
              },
            );
          },
        ),
      ),
    );
  }
}