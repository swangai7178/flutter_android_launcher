import 'dart:convert';
import 'dart:typed_data';

class AppModel {
  final String name;
  final String package;
  final Uint8List? icon;

  AppModel({
    required this.name,
    required this.package,
    this.icon,
  });

  factory AppModel.fromMap(Map<dynamic, dynamic> map) {
    Uint8List? decoded;
    if (map['icon'] != null) {
      try {
        final base64Data = map['icon'].split(',').last.replaceAll('\n', '');
        decoded = Uint8List.fromList(const Base64Decoder().convert(base64Data));
      } catch (_) {}
    }
    return AppModel(
      name: map['name'] ?? '',
      package: map['package'] ?? '',
      icon: decoded,
    );
  }
}
