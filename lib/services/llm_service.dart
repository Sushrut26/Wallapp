import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import '../utils/input_validator.dart';

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

class LLMService {
  // Default Ollama endpoint running locally
  final String baseUrl;
  final String model;
  DateTime? _lastRequestTime;
  static const _rateLimitDuration = Duration(seconds: 2);

  LLMService({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama2',
  });

  /// Validate that the URL uses HTTPS if not localhost
  bool _isSecureEndpoint(String url) {
    final uri = Uri.parse(url);
    return uri.scheme == 'https' ||
           uri.host == 'localhost' ||
           uri.host == '127.0.0.1' ||
           uri.host.startsWith('192.168.') ||
           uri.host.startsWith('10.');
  }

  Future<String> generateMealSuggestion({
    required String category,
    required List<Meal> mealHistory,
    String? preferences,
  }) async {
    // Rate limiting to prevent abuse
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _rateLimitDuration) {
        await Future.delayed(_rateLimitDuration - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();

    // Validate URL security
    if (!_isSecureEndpoint(baseUrl)) {
      throw SecurityException('LLM endpoint must use HTTPS for remote servers');
    }

    // Sanitize inputs to prevent prompt injection
    final sanitizedCategory = InputValidator.sanitizeForLLM(category);
    final sanitizedPreferences = preferences != null
        ? InputValidator.sanitizeForLLM(preferences)
        : 'No specific preferences';

    // Build context from meal history with sanitization
    final historyContext = mealHistory.isEmpty
        ? 'No previous meal history available.'
        : 'Previous meals:\n${mealHistory.take(5).map((m) {
            final safeName = InputValidator.sanitizeForLLM(m.name);
            final safeDesc = InputValidator.sanitizeForLLM(m.description);
            return '- $safeName: $safeDesc';
          }).join('\n')}';

    final prompt = '''
You are a helpful vegetarian meal planning assistant. Generate a vegetarian meal suggestion for $sanitizedCategory.

$historyContext

Requirements:
- Must be vegetarian (no meat, fish, or poultry)
- Category: $sanitizedCategory
- $sanitizedPreferences

Please suggest a meal with the following format:
Name: [Meal Name]
Description: [Brief description]
Ingredients: [Comma-separated list of ingredients]

Keep it simple and practical for home cooking.
''';

    try {
      // Try to connect to Ollama API
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestion = data['response'] as String?;
        if (suggestion != null && suggestion.isNotEmpty) {
          return suggestion;
        }
        return _getFallbackSuggestion(sanitizedCategory);
      } else {
        return _getFallbackSuggestion(sanitizedCategory);
      }
    } catch (e) {
      // If Ollama is not available, return fallback suggestions
      return _getFallbackSuggestion(sanitizedCategory);
    }
  }

  String _getFallbackSuggestion(String category) {
    // Fallback suggestions when LLM is not available
    final suggestions = {
      'breakfast': '''
Name: Poha (Flattened Rice)
Description: A light and flavorful Indian breakfast made with flattened rice, vegetables, and spices
Ingredients: Poha (flattened rice), onions, potatoes, green chilies, curry leaves, turmeric, mustard seeds, peanuts, lemon juice
''',
      'lunch': '''
Name: Paneer Tikka Masala with Rice
Description: Cottage cheese cubes in a rich, creamy tomato-based gravy served with basmati rice
Ingredients: Paneer, tomatoes, onions, cream, cashews, ginger-garlic paste, Indian spices, basmati rice
''',
      'dinner': '''
Name: Mixed Vegetable Curry with Roti
Description: A wholesome curry with seasonal vegetables served with whole wheat flatbread
Ingredients: Mixed vegetables (carrots, beans, peas, cauliflower), onions, tomatoes, ginger-garlic, Indian spices, whole wheat flour
''',
      'snack': '''
Name: Masala Dosa
Description: Crispy rice and lentil crepe filled with spiced potato filling
Ingredients: Dosa batter (rice and urad dal), potatoes, onions, mustard seeds, curry leaves, turmeric, green chilies
''',
    };

    return suggestions[category.toLowerCase()] ??
        suggestions['lunch']!;
  }
}
