import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LauncherApp());
}

class LauncherApp extends StatelessWidget {
  const LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  static const platform = MethodChannel('com.example.launcher/apps');
  List<dynamic> _apps = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadApps);
  }

  Future<void> _loadApps() async {
  try {
    final result = await platform.invokeMethod('getInstalledApps');
    setState(() {
      _apps = (result as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  } on PlatformException catch (e) {
    print("⚠️ Error loading apps: ${e.message}");
  } catch (e) {
    print("⚠️ Error loading apps: $e");
  }
}


  Uint8List? _decodeIcon(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("⚠️ Invalid Base64 icon: $e");
      return null;
    }
  }

  void _launchApp(String packageName) async {
    try {
      await platform.invokeMethod('launchApp', {'packageName': packageName});
    } catch (e) {
      print("⚠️ Error launching app: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _apps.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _apps.length,
                itemBuilder: (context, index) {
                  final app = _apps[index];
                  final icon = _decodeIcon(app['iconBase64']);
                  return GestureDetector(
                    onTap: () => _launchApp(app['packageName']),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(icon, width: 50, height: 50),
                          )
                        else
                          const Icon(Icons.android, size: 50, color: Colors.grey),
                        const SizedBox(height: 6),
                        Text(
                          app['appName'] ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
