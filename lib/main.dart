import 'dart:convert';
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
  String _time = '';
  String _date = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = DateFormat('HH:mm:ss').format(now);
      _date = DateFormat('EEEE, MMMM d, yyyy').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
  children: [
    // 🔷 Background logo watermark (slightly more visible)
    Align(
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.12, // increased from 0.05 → more visible
        child: Image.asset(
          'assets/icons/icon.png',
          width: 300,
        ),
      ),
    ),

    // 🔷 Foreground content
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        Text(
          _time,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _date,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 16,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Welcome back, Wangai Samuel",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            fontFamily: 'Courier',
          ),
        ),
        const Spacer(),

        // 🔷 Bottom Icon Dock
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 📱 SIM Toolkit Icon
              IconButton(
                iconSize: 45,
                icon: const Icon(Icons.sim_card, color: Colors.greenAccent),
                onPressed: () async {
                  try {
                    await const MethodChannel('com.yourlauncher/apps')
                        .invokeMethod('openApp', {"package": "com.android.stk"});
                  } catch (e) {
                    debugPrint("Failed to open SIM Toolkit: $e");
                  }
                },
              ),
              IconButton(
                iconSize: 45,
                icon: const Icon(Icons.call, color: Colors.greenAccent),
                onPressed: () async {
                  try {
                    await const MethodChannel('com.yourlauncher/apps')
                        .invokeMethod('openApp', {"package": "com.google.android.dialer"});
                  } catch (e) {
                    debugPrint("Failed to open SIM Toolkit: $e");
                  }
                },
              ),
              // 🚀 Open Apps Icon (Main launcher button)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppsPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.apps,
                    size: 35,
                    color: Colors.greenAccent,
                  ),
                ),
              ),

              // 💬 Messages Icon
              IconButton(
                iconSize: 45,
                icon: const Icon(Icons.message, color: Colors.greenAccent),
                onPressed: () async {
                  try {
                    await const MethodChannel('com.yourlauncher/apps')
                        .invokeMethod('openApp', {"package": "com.google.android.apps.messaging"});
                  } catch (e) {
                    debugPrint("Failed to open Messages: $e");
                  }
                },
              ),
            ],
          ),
        ),

        // 🖋️ Signature
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            "WS Launcher",
            style: TextStyle(
              color: Colors.greenAccent.withOpacity(0.7),
              fontFamily: 'Courier',
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  ],
)

    );
  }
}

// =================== APP LIST PAGE ===================

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  static const platform = MethodChannel('com.yourlauncher/apps');
  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Installed Apps",
          style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/icons/icon.png', width: 250),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                Expanded(
                  child: _loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.greenAccent),
                        )
                      : _filteredApps.isEmpty
                          ? const Center(
                              child: Text(
                                "No apps found.",
                                style: TextStyle(color: Colors.greenAccent),
                              ),
                            )
                          : ListView.builder(
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
          ],
        ),
      ),
    );
  }
}
