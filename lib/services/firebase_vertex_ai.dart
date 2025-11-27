
import 'dart:typed_data';

// Mock implementation to satisfy the analyzer.
// In a real scenario, this would be part of the firebase_ai package.

class FirebaseVertexAI {
  static FirebaseVertexAI get instance => FirebaseVertexAI();

  GenerativeModel generativeModel({required String model}) {
    return GenerativeModel();
  }
}

class GenerativeModel {
  Future<GenerateContentResponse> generateContent(List<Content> content) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));
    // Simulate a successful response with empty data
    return GenerateContentResponse([]);
  }
}

class Content {
  final List<Part> parts;
  Content(this.parts);

  static Content text(String text) {
    return Content([TextPart(text)]);
  }

  static Content multi(List<Part> parts) {
    return Content(parts);
  }
}

abstract class Part {}

class TextPart implements Part {
  final String text;
  TextPart(this.text);
}

class DataPart implements Part {
  final String mimeType;
  final Uint8List bytes;
  DataPart(this.mimeType, this.bytes);
}

class GenerateContentResponse {
  final List<Part> parts;

  GenerateContentResponse(this.parts);

  String? get text {
    try {
      return parts.whereType<TextPart>().map((part) => part.text).join('');
    } catch (e) {
      return null;
    }
  }
}
