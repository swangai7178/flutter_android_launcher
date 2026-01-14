import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/appmodels.dart';

// --- State Definition ---
enum AppStatus { initial, loading, success, failure }

class AppsState extends Equatable {
  final List<AppModel> apps;
  final List<AppModel> filteredApps;
  final AppStatus status;
  final String searchQuery;

  const AppsState({
    this.apps = const [],
    this.filteredApps = const [],
    this.status = AppStatus.initial,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [apps, filteredApps, status, searchQuery];

  AppsState copyWith({
    List<AppModel>? apps,
    List<AppModel>? filteredApps,
    AppStatus? status,
    String? searchQuery,
  }) {
    return AppsState(
      apps: apps ?? this.apps,
      filteredApps: filteredApps ?? this.filteredApps,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// --- Bloc Implementation ---
class AppsBloc extends HydratedCubit<AppsState> {
  static const MethodChannel _channel = MethodChannel('com.yourlauncher/apps');

  AppsBloc() : super(const AppsState()) {
    // Refresh apps on every startup, but UI will use hydrated state immediately
    loadApps();
  }

  /// Fetches apps and handles icon caching to local files
  Future<void> loadApps() async {
    if (state.apps.isEmpty) {
      emit(state.copyWith(status: AppStatus.loading));
    }

    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result == null) return;

      final List<Map> rawApps = List<Map>.from(result);
      final directory = await getApplicationDocumentsDirectory();
      final iconsDir = Directory(p.join(directory.path, 'app_icons'));

      if (!await iconsDir.exists()) {
        await iconsDir.create(recursive: true);
      }

      // Process apps in the background to avoid UI lag
      final List<AppModel> processed = await compute(_processAppsTask, {
        'rawApps': rawApps,
        'iconsDirPath': iconsDir.path,
      });

      emit(state.copyWith(
        apps: processed,
        filteredApps: _applySearch(processed, state.searchQuery),
        status: AppStatus.success,
      ));
    } catch (e) {
      debugPrint("Error loading apps: $e");
      emit(state.copyWith(status: AppStatus.failure));
    }
  }

  /// Top-level function for compute() to handle heavy decoding and file checks
  static List<AppModel> _processAppsTask(Map<String, dynamic> data) {
    final List<Map> rawApps = data['rawApps'];
    final String iconsDirPath = data['iconsDirPath'];
    
    return rawApps.map((map) {
      final String package = map['package'];
      final String name = map['name'];
      final String expectedPath = p.join(iconsDirPath, '$package.png');
      
      String? finalPath;
      if (File(expectedPath).existsSync()) {
        finalPath = expectedPath;
      } else if (map['icon'] != null) {
        // Decode Base64 and save to file
        try {
          final bytes = base64Decode(map['icon'].split(',').last.replaceAll('\n', ''));
          File(expectedPath).writeAsBytesSync(bytes);
          finalPath = expectedPath;
        } catch (_) {}
      }

      return AppModel(
        name: name,
        package: package,
        iconPath: finalPath,
      );
    }).toList();
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredApps: _applySearch(state.apps, query),
    ));
  }

  static List<AppModel> _applySearch(List<AppModel> apps, String query) {
    if (query.isEmpty) return apps;
    final lower = query.toLowerCase();
    return apps.where((app) => app.name.toLowerCase().contains(lower)).toList();
  }

  Future<void> openApp(String package) async {
    try {
      await _channel.invokeMethod('openApp', {"package": package});
    } catch (e) {
      debugPrint("Launch Error: $e");
    }
  }

  Future<void> openAppByName(String name) async {
    try {
      final match = state.apps.firstWhere(
        (app) => app.name.toLowerCase().contains(name.toLowerCase()),
      );
      await openApp(match.package);
    } catch (_) {}
  }

  // --- Hydration Logic ---
  @override
  AppsState? fromJson(Map<String, dynamic> json) {
    try {
      final apps = (json['apps'] as List)
          .map((appJson) => AppModel.fromMap(appJson))
          .toList();
      return AppsState(
        apps: apps,
        filteredApps: apps,
        status: AppStatus.success,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AppsState state) {
    return {
      'apps': state.apps.map((app) => {
        'name': app.name,
        'package': app.package,
        'iconPath': app.iconPath,
      }).toList(),
    };
  }
}