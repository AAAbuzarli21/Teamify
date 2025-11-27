import 'package:flutter/foundation.dart';

class Formation {
  final String id;
  final String name;
  final List<List<String>> layout;

  const Formation({
    this.id = '', // Default value for Firestore documents
    required this.name,
    required this.layout,
  });

  factory Formation.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Formation(
      id: documentId,
      name: data['name'] as String,
      layout: (data['layout'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).cast<String>())
          .toList(),
    );
  }

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      layout: (json['layout'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).cast<String>())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'layout': layout,
    };
  }

  // For comparing formations in the dropdown
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formation &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listEquals(layout, other.layout);

  @override
  int get hashCode => name.hashCode ^ layout.hashCode;
}
