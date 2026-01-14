import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppModel extends Equatable {
  final String name;
  final String package;
  final Uint8List? iconBytes; // Used for first load
  final String? iconPath;    // Used for persistent storage

  const AppModel({
    required this.name,
    required this.package,
    this.iconBytes,
    this.iconPath,
  });

  @override
  List<Object?> get props => [name, package, iconPath];

  // Helper to get the image provider
  ImageProvider? get iconProvider {
    if (iconPath != null) return FileImage(File(iconPath!));
    if (iconBytes != null) return MemoryImage(iconBytes!);
    return null;
  }

  factory AppModel.fromMap(Map<String, dynamic> map) {
    return AppModel(
      name: map['name'] ?? '',
      package: map['package'] ?? '',
      iconPath: map['iconPath'],
    );
  }
}