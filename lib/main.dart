import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LauncherApp());
}

class LauncherApp extends StatefulWidget {
  const LauncherApp({super.key});

  @override
  State<LauncherApp> createState() => _LauncherAppState();
}

class _LauncherAppState extends State<LauncherApp> {
  static const platform = MethodChannel('com.example.launcher/apps');

  List<Map<String, dynamic>> _apps = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final List<dynamic> apps = await platform.invokeMethod('getAllApps');
      setState(() {
        _apps = apps.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = e.message ?? 'Error loading apps';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _launchApp(String packageName) async {
    try {
      await platform.invokeMethod('launchApp', {'package': packageName});
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching app: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Launcher',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _apps.length,
                      itemBuilder: (context, index) {
                        final app = _apps[index];
                        final iconBytes = app['icon'] != null
                            ? (app['icon'] as List<dynamic>).cast<int>()
                            : null;

                        return GestureDetector(
                          onTap: () => _launchApp(app['package']),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (iconBytes != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    Uint8List.fromList(iconBytes),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const Icon(Icons.apps, size: 48, color: Colors.white),
                              const SizedBox(height: 8),
                              Text(
                                app['name'] ?? 'Unknown',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
