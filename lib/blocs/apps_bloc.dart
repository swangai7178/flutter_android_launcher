
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:launcher/models/appmodels.dart';


class AppsState {
  final List<AppModel> apps;
  final List<AppModel> filteredApps;
  final bool loading;

  const AppsState({
    this.apps = const [],
    this.filteredApps = const [],
    this.loading = false,
  });

  AppsState copyWith({
    List<AppModel>? apps,
    List<AppModel>? filteredApps,
    bool? loading,
  }) {
    return AppsState(
      apps: apps ?? this.apps,
      filteredApps: filteredApps ?? this.filteredApps,
      loading: loading ?? this.loading,
    );
  }
}

class AppsBloc extends Cubit<AppsState> {
  static const MethodChannel _channel = MethodChannel('com.yourlauncher/apps');

  AppsBloc() : super(const AppsState(loading: true)) {
    loadApps();
  }

  Future<void> loadApps() async {
    emit(state.copyWith(loading: true));
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      final List<Map<String, dynamic>> appsList =
          List<Map>.from(result).map((e) => Map<String, dynamic>.from(e)).toList();

      final processed = await compute(_decodeApps, appsList);
      emit(AppsState(apps: processed, filteredApps: processed, loading: false));
    } catch (e) {
      emit(const AppsState(apps: [], filteredApps: [], loading: false));
    }
  }

  static List<AppModel> _decodeApps(List<Map<String, dynamic>> apps) {
    return apps.map((e) => AppModel.fromMap(e)).toList();
  }

  void search(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredApps: state.apps));
    } else {
      final lower = query.toLowerCase();
      final filtered = state.apps
          .where((app) => app.name.toLowerCase().contains(lower))
          .toList();
      emit(state.copyWith(filteredApps: filtered));
    }
  }

  Future<void> openApp(String package) async {
    try {
      await _channel.invokeMethod('openApp', {"package": package});
    } catch (_) {}
  }

  Future<void> openAppByName(String name) async {
    final match = state.apps.firstWhere(
      (app) => app.name.toLowerCase().contains(name.toLowerCase()),
      orElse: () => AppModel(name: '', package: '', icon: null),
    );
    if (match.package.isNotEmpty) {
      await openApp(match.package);
    }
  }
}
