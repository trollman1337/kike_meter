import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kike Search Engine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String _result = '';
  bool _loading = false;
  bool _saveDetails = false; // Single checkbox for both settings
  String? _serverHost;
  String? _serverPort;
  String? _accessKey;

  @override
  void initState() {
    super.initState();
    _loadServerInfo();
  }

  // Load saved server info and API key from SharedPreferences
  Future<void> _loadServerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverHost = prefs.getString('serverHost');
      _serverPort = prefs.getString('serverPort');
      _accessKey = prefs.getString('accessKey');
      _ipController.text = _serverHost ?? '';
      _portController.text = _serverPort ?? '';
      _apiKeyController.text = _accessKey ?? '';
      _saveDetails = _serverHost != null && _serverPort != null && _accessKey != null;
    });
  }

  // Save server info and API key to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveDetails) {
      await prefs.setString('serverHost', _serverHost ?? '');
      await prefs.setString('serverPort', _serverPort ?? '');
      await prefs.setString('accessKey', _accessKey ?? '');
    } else {
      await prefs.remove('serverHost');
      await prefs.remove('serverPort');
      await prefs.remove('accessKey');
    }
  }

  // Fetch Wikipedia content from the server
  Future<http.Response> fetchWikipediaContent(String url) async {
    try {
      final proxyUrl = 'http://${_serverHost}:${_serverPort}/fetch?url=${Uri.encodeComponent(url)}';
      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {
          'x-access-key': _accessKey ?? '', // Use the saved access key
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      final bodySnippet = response.body.length <= 100
          ? response.body
          : response.body.substring(0, 100);
      print('Response Body: $bodySnippet');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      print('Error fetching content: $e');
      rethrow;
    }
  }

  void _search() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _result = 'Please enter a person\'s name.';
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final url = 'https://en.wikipedia.org/wiki/$name';
      final response = await fetchWikipediaContent(url);
      final htmlContent = response.body;

      final document = parser.parse(htmlContent);
      final bodyText = document.body?.text ?? '';

      final sentences = bodyText.split(RegExp(r'(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s'));

      final firstMatchingSentence = sentences.firstWhere(
        (sentence) => sentence.toLowerCase().contains('jew'),
        orElse: () => '',
      );

      setState(() {
        if (firstMatchingSentence.isNotEmpty) {
          _result = 'Oi Vey goyim,\n\n$firstMatchingSentence';
        } else {
          _result = 'The substring "jew" was not found in any sentence.';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }

    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kike Search Engine'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Server IP TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'Server IP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _serverHost = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              // Server Port TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: 'Server Port',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _serverPort = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              // Access Key TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'Access Key',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _accessKey = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              // Save Details Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _saveDetails,
                    onChanged: (bool? value) {
                      setState(() {
                        _saveDetails = value ?? false;
                      });
                    },
                  ),
                  Text('Save Server Info and Access Key'),
                ],
              ),
              SizedBox(height: 16),
              // Search TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Search Wikipedia for Person',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Search Button
              Center(
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  ),
                  child: Text('Search'),
                ),
              ),
              SizedBox(height: 16),
              // Loading Indicator
              if (_loading)
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                    ),
                  ),
                )
              else if (_result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SelectableText(
                    _result,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
