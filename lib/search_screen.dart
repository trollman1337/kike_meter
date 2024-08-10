import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollable Page Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  bool _darkMode = false;
  bool _saveDetails = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  void _loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _serverController.text = prefs.getString('server') ?? '';
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _saveDetails = prefs.getBool('save_details') ?? false;
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_saveDetails) {
      prefs.setString('api_key', _apiKeyController.text);
      prefs.setString('server', _serverController.text);
    }
    prefs.setBool('dark_mode', _darkMode);
    prefs.setBool('save_details', _saveDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrollable Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(labelText: 'API Key'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _serverController,
                      decoration: InputDecoration(labelText: 'Server Hostname:Port'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _saveDetails,
                          onChanged: (value) {
                            setState(() {
                              _saveDetails = value ?? false;
                            });
                            _savePreferences();
                          },
                        ),
                        Text('Save API Key and Server Details'),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _savePreferences();
                        final serverInfo = 'API Key: ${_apiKeyController.text}\n'
                            'Server: ${_serverController.text}';
                        print('Saved Server Info:\n$serverInfo');
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
