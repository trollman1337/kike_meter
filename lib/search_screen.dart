import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

// Function to fetch Wikipedia content
Future<http.Response> fetchWikipediaContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load content');
  }
}

// Function to extract relevant sections from the Wikipedia page
Map<String, String> extractRelevantSections(String htmlContent) {
  final document = parser.parse(htmlContent);
  final sections = <String, String>{};

  // Define possible relevant headings
  final relevantHeadings = [
    'Early life',
    'Personal life',
    'Life and career',
    'Early life and background',
    'Biography',
    'Background',
    'Career',
    // Add more headings as needed
  ];

  final headingElements = document.querySelectorAll('h2, h3, h4');

  for (var headingElement in headingElements) {
    final headingText = headingElement.text.trim();

    if (relevantHeadings.any((heading) => headingText.contains(heading))) {
      final buffer = StringBuffer();
      var nextElement = headingElement.nextElementSibling;

      while (nextElement != null && !nextElement.localName!.startsWith('h')) {
        if (nextElement.localName == 'p' || nextElement.localName == 'ul' || nextElement.localName == 'div') {
          buffer.writeln(nextElement.text.trim());
        }
        nextElement = nextElement.nextElementSibling;
      }

      sections[headingText] = buffer.toString().trim();
    }
  }

  return sections;
}

// Function to search specifically for the substring "jew" in sections
bool searchInSections(String sectionsText) {
  if (sectionsText.isEmpty) {
    return false;
  }

  return sectionsText.toLowerCase().contains('jew');
}

void main() async {
  final url = 'https://en.wikipedia.org/wiki/Some_Article'; // Replace with the actual URL
  try {
    final response = await fetchWikipediaContent(url);
    final sections = extractRelevantSections(response.body);

    for (var entry in sections.entries) {
      if (searchInSections(entry.value)) {
        print('Found "jew" in section: ${entry.key}');
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
