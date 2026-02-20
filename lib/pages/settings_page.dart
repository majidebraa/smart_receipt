import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    loadSetting();
  }

  Future<void> loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      biometricEnabled = prefs.getBool("biometric_enabled") ?? false;
    });
  }

  Future<void> saveSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("biometric_enabled", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),

      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Enable biometric login"),
            subtitle: Text("Require Face ID / Touch ID when opening the app for protect your data"),
            value: biometricEnabled,
            onChanged: (value) async {
              setState(() => biometricEnabled = value);
              await saveSetting(value);
            },
          ),
        ],
      ),
    );
  }
}