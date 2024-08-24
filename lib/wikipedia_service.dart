import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchWikipediaContent(String person) async {
  final response = await http.get(Uri.parse(
    'https://en.wikipedia.org/w/api.php?action=parse&page=${Uri.encodeComponent(person)}&prop=text&format=json',
  ));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['parse']['text']['*'];
  } else {
    throw Exception('Failed to load Wikipedia content');
  }
}
