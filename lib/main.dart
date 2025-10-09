import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() => runApp(const MyLauncherApp());

class MyLauncherApp extends StatelessWidget {
  const MyLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "WS Launcher",
      debugShowCheckedModeBanner: false,
      home: LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  static const platform = MethodChannel('com.yourlauncher/apps');
  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  bool _loading = true;
  String _searchQuery = '';
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadApps();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  Future<void> _loadApps() async {
    try {
      final result = await platform.invokeMethod('getInstalledApps');
      final List<Map<String, dynamic>> decoded =
          await compute(_processAppsInBackground, List<Map>.from(result));

      setState(() {
        _apps = decoded;
        _filteredApps = decoded;
        _loading = false;
      });
    } catch (e) {
      debugPrint("⚠️ Error loading apps: $e");
      setState(() => _loading = false);
    }
  }

  static List<Map<String, dynamic>> _processAppsInBackground(List<Map> apps) {
    return apps.map((e) {
      final Map<String, dynamic> app = Map<String, dynamic>.from(e);
      app['icon'] = app['icon'] != null
          ? base64Decode(app['icon'].split(',').last.replaceAll('\n', ''))
          : null;
      return app;
    }).toList();
  }

  void _searchApps(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredApps = _apps
          .where((app) =>
              app['name'].toString().toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  Future<void> _openApp(String packageName) async {
    try {
      await platform.invokeMethod('openApp', {"package": packageName});
    } on PlatformException catch (e) {
      debugPrint("Failed to open app: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background watermark
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/icons/icon.png', // <- Add your logo in assets
                  width: 250,
                ),
              ),
            ),

            // Foreground content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Welcome to WS Launcher",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    style: const TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle:
                          const TextStyle(color: Colors.greenAccent, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.greenAccent),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.greenAccent, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _searchApps,
                  ),
                ),
                const SizedBox(height: 10),

                // App list
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.greenAccent),
                        )
                      : _filteredApps.isEmpty
                          ? const Center(
                              child: Text(
                                "No apps found.",
                                style: TextStyle(color: Colors.greenAccent),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _filteredApps.length,
                              itemBuilder: (context, index) {
                                final app = _filteredApps[index];
                                return ListTile(
                                  onTap: () => _openApp(app['package']),
                                  leading: app['icon'] != null
                                      ? Image.memory(
                                          app['icon'],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) =>
                                              const Icon(Icons.apps,
                                                  color: Colors.greenAccent),
                                        )
                                      : const Icon(Icons.apps,
                                          color: Colors.greenAccent),
                                  title: Text(
                                    app['name'],
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontFamily: 'Courier'),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),

            // Signature footer
            Positioned(
              bottom: 15,
              right: 15,
              child: Text(
                "Wangai Samuel",
                style: TextStyle(
                  color: Colors.greenAccent.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Courier',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
