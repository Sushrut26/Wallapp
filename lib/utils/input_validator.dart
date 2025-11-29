class InputValidator {
  // Maximum lengths to prevent abuse
  static const int maxTitleLength = 200;
  static const int maxDescriptionLength = 1000;
  static const int maxIngredientLength = 100;
  static const int maxLocationLength = 200;
  static const int maxIngredientsCount = 50;

  /// Sanitize string input to prevent injection attacks
  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[<>{}]'), '') // Remove potential code injection chars
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Validate and sanitize title input
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.length > maxTitleLength) {
      return 'Title must be less than $maxTitleLength characters';
    }
    return null;
  }

  /// Validate description (optional)
  static String? validateDescription(String? value) {
    if (value != null && value.length > maxDescriptionLength) {
      return 'Description must be less than $maxDescriptionLength characters';
    }
    return null;
  }

  /// Validate location
  static String? validateLocation(String? value) {
    if (value != null && value.length > maxLocationLength) {
      return 'Location must be less than $maxLocationLength characters';
    }
    return null;
  }

  /// Sanitize ingredients list
  static List<String> sanitizeIngredients(List<String> ingredients) {
    return ingredients
        .map((ing) => sanitize(ing))
        .where((ing) => ing.isNotEmpty)
        .take(maxIngredientsCount)
        .toList();
  }

  /// Validate ingredient
  static String? validateIngredient(String? value) {
    if (value != null && value.length > maxIngredientLength) {
      return 'Ingredient must be less than $maxIngredientLength characters';
    }
    return null;
  }

  /// Check if date is valid
  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365 * 2)); // 2 years in future
    final minDate = now.subtract(const Duration(days: 365 * 2)); // 2 years in past
    return date.isAfter(minDate) && date.isBefore(maxDate);
  }

  /// Sanitize for LLM prompts - prevent prompt injection
  static String sanitizeForLLM(String input) {
    return input
        .replaceAll(RegExp(r'[<>{}]'), '')
        .replaceAll(RegExp(r'system:', caseSensitive: false), 'sys-tem:')
        .replaceAll(RegExp(r'user:', caseSensitive: false), 'us-er:')
        .replaceAll(RegExp(r'assistant:', caseSensitive: false), 'assis-tant:')
        .replaceAll(RegExp(r'###'), '')
        .replaceAll(RegExp(r'\[INST\]'), '')
        .replaceAll(RegExp(r'\[/INST\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, input.length > 500 ? 500 : input.length); // Max 500 chars for LLM
  }
}
