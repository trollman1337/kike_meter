import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Substring Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light, // Automatically adapts based on system settings
        // To automatically handle dark mode, omit brightness or set it to null.
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system, // Use system theme mode
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
  String _result = '';
  bool _loading = false;

  // Fetch Wikipedia content
  Future<http.Response> fetchWikipediaContent(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load content');
    }
  }

  // Find the first sentence containing the substring "jew"
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
        _result = 'Error fetching data.';
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
        title: Text('Kike Search Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Smaller padding
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
                  child: Text(_result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}