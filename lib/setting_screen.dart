import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _selectedColor = 'white';
  double _boardTop = 50.0;
  double _boardLeft = 50.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedColor = prefs.getString('selectedColor') ?? 'white';
      _boardTop = prefs.getDouble('boardTop') ?? 50.0;
      _boardLeft = prefs.getDouble('boardLeft') ?? 50.0;
    });
  }

  _saveColorPreference(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedColor', color);
    setState(() {
      _selectedColor = color;
    });
  }

  _saveBoardPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('boardTop', _boardTop);
    prefs.setDouble('boardLeft', _boardLeft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Select Piece Color'),
            subtitle: Text('Choose the color you want to play as'),
          ),
          RadioListTile<String>(
            title: const Text('White'),
            value: 'white',
            groupValue: _selectedColor,
            onChanged: (String? value) {
              if (value != null) {
                _saveColorPreference(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Black'),
            value: 'black',
            groupValue: _selectedColor,
            onChanged: (String? value) {
              if (value != null) {
                _saveColorPreference(value);
              }
            },
          ),
          ListTile(
            title: Text('Board Position - Top'),
            subtitle: Slider(
              value: _boardTop,
              min: 0,
              max: 100,
              divisions: 100,
              label: _boardTop.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _boardTop = value;
                });
                _saveBoardPosition();
              },
            ),
          ),
          ListTile(
            title: Text('Board Position - Left'),
            subtitle: Slider(
              value: _boardLeft,
              min: -20,
              max: 120,
              divisions: 120,
              label: _boardLeft.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _boardLeft = value;
                });
                _saveBoardPosition();
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showLicensePage(
                context: context,
                applicationName: 'ChessKing',
                applicationVersion: '1.0.5',
                applicationLegalese: '© 2024 by ChessKing',
              );
            },
            child: Text("저작권 고지"),
          ),

        ],
      ),
    );
  }
}
