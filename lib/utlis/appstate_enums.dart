import 'package:launcher/models/appmodels.dart';
import 'package:equatable/equatable.dart';

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