import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyLauncherApp());

class MyLauncherApp extends StatelessWidget {
  const MyLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LauncherHome(),
      debugShowCheckedModeBanner: false,
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

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final result = await platform.invokeMethod('getInstalledApps');
      setState(() {
        _apps = List<Map>.from(result)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      debugPrint("⚠️ Error loading apps: $e");
    }
  }

  // 🐛 FIX: Clean the Base64 string of newlines and spaces before decoding.
  Uint8List _decodeIcon(String base64String) {
    // 1. Remove optional "data:image/png;base64," prefix and get the Base64 part
    final String base64Part = base64String.split(',').last;
    
    // 2. Remove any newline or space characters introduced by Base64.DEFAULT on Android
    final String cleanBase64 = base64Part.replaceAll('\n', '').replaceAll(' ', '');

    return base64Decode(cleanBase64);
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
        child: _apps.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _apps.length,
                itemBuilder: (context, index) {
                  final app = _apps[index];
                  return GestureDetector(
                    onTap: () => _openApp(app['package']),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _decodeIcon(app['icon']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app['name'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
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