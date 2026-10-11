import 'tokenizer.dart';

/// Intent detection engine for natural language offline GPS queries.
class AiIntentEngine {
  final Tokenizer _tokenizer = Tokenizer();

  Future<String> detectIntent(String text) async {
    final tokens = _tokenizer.tokenize(text);

    if (tokens.contains('gas') || tokens.contains('fuel') || tokens.contains('petrol')) {
      return 'search_gas_station';
    }
    if (tokens.contains('hospital') || tokens.contains('clinic') || tokens.contains('emergency') || tokens.contains('medical')) {
      return 'search_hospital';
    }
    if (tokens.contains('coffee') || tokens.contains('cafe') || tokens.contains('restaurant') || tokens.contains('food') || tokens.contains('dining')) {
      return 'search_food';
    }
    if (tokens.contains('navigate') || tokens.contains('direction') || tokens.contains('route') || tokens.contains('to')) {
      return 'navigate_to';
    }
    return 'search_poi';
  }
}
