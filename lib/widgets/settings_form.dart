import 'package:flutter/material.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final formKey = GlobalKey<FormState>();

  void saveKeyValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = SharedPreferences.getInstance();
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: false);

    return Form(
      key: formKey,
      child: FutureBuilder(
        future: prefs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load settings'));
          } else {
            final SharedPreferences prefs = snapshot.data as SharedPreferences;
            final serverAddress = prefs.getString('server_address') ?? '';
            final serverPort = prefs.getString('server_port') ?? '';
            final roomCode = prefs.getString('room_code') ?? '';

            return Column(
              spacing: 16.0,
              children: [
                TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Server address',
                  ),
                  initialValue: serverAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server address';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      saveKeyValue('server_address', newValue);
                    }
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Server port',
                  ),
                  initialValue: serverPort,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server port';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      saveKeyValue('server_port', newValue);
                    }
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Room code',
                  ),
                  initialValue: roomCode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room code';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      saveKeyValue('room_code', newValue);
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      appViewmodel.loadSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings saved')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        },
      )
    );
  }
}