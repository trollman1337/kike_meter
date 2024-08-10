import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';
  bool _loading = false;
  bool _isAccepted = false;
  String _accessKey = '';

  @override
  void initState() {
    super.initState();
    _loadAccessKey();
  }

  // Load the saved access key from local storage
  Future<void> _loadAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessKey = prefs.getString('access_key') ?? '';
      _keyController.text = _accessKey;
      _isAccepted = _accessKey.isNotEmpty; // Check if key exists
    });
  }

  // Save the access key to local storage
  Future<void> _saveAccessKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_key', key);
  }

  Future<http.Response> fetchWikipediaContent(String url) async {
    try {
      final proxyUrl = 'http://localhost:4000/fetch?url=${Uri.encodeComponent(url)}';
      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {
          'x-access-key': _accessKey, // Use the saved access key
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      // Safely handle the body length to prevent RangeError
      final bodySnippet = response.body.length <= 100
          ? response.body
          : response.body.substring(0, 100);
      print('Response Body: $bodySnippet'); // Print first 100 characters or the entire body if it's shorter

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

      // Parse the HTML and get the body text
      final document = parser.parse(htmlContent);
      final bodyText = document.body?.text ?? '';

      // Split text into sentences
      final sentences = bodyText.split(RegExp(r'(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s'));

      // Find the first sentence containing the substring "jew"
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kike Search Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Access Key Input
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'Enter API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              onChanged: (value) {
                _accessKey = value;
              },
            ),
            SizedBox(height: 16),
            // Access Key Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAccepted = value ?? false;
                      if (_isAccepted && _accessKey.isNotEmpty) {
                        _saveAccessKey(_accessKey);
                      } else {
                        _accessKey = '';
                        _saveAccessKey(_accessKey);
                      }
                    });
                  },
                ),
                Text('I accept and save the access key'),
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
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
