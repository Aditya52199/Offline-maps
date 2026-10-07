/// Simple placeholder tokenizer.
/// Replace with the tokenizer matching assets/models/vocab.txt.
class Tokenizer {
  List<String> tokenize(String text) {
    return text.toLowerCase().trim().split(RegExp(r'\s+'));
  }
}
