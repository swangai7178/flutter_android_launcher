import 'dart:async'; // Required for the Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for MethodChannel
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/pages/apps_pages.dart';
import 'package:launcher/utlis/terminalpopup_widget.dart';
import '../blocs/time_bloc.dart';
import '../blocs/apps_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Define the same channel name used in your MainActivity.kt
  static const _channel = MethodChannel('com.yourlauncher/apps');

  // State variables to hold real system data
  String _batteryLevel = "--%";
  String _ramAvailable = "-.-GB";
  Timer? _systemTimer;

  @override
  void initState() {
    super.initState();
    _updateSystemStats();
    // Refresh the data every 5 seconds to keep it "live"
    _systemTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateSystemStats();
    });
  }

  @override
  void dispose() {
    _systemTimer?.cancel(); // Clean up the timer when the widget is destroyed
    super.dispose();
  }

  Future<void> _updateSystemStats() async {
    try {
      // Fetch data from Kotlin
      final int battery = await _channel.invokeMethod('getBatteryLevel');
      final int ramMB = await _channel.invokeMethod('getRamInfo');

      if (mounted) {
        setState(() {
          _batteryLevel = "$battery%";
          // Convert MB to GB (1024 MB = 1 GB)
          _ramAvailable = "${(ramMB / 1024).toStringAsFixed(1)}GB";
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch system stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsBloc = context.read<AppsBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackgroundGrid(),
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/icons/icon.png', width: 400),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderStatus(context),
                  const Spacer(),
                  _buildClockSection(),
                  const Spacer(),
                  _buildSystemWidgets(), // Now uses real state variables
                  const SizedBox(height: 40),
                  _buildBottomDock(context, appsBloc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic for updated System Widgets ---
  Widget _buildSystemWidgets() {
    return Row(
      children: [
        _infoWidget("BATTERY", _batteryLevel),
        const SizedBox(width: 15),
        _infoWidget("STATUS", "STABLE"), // You can make this dynamic later
        const SizedBox(width: 15),
        _infoWidget("RAM_FREE", _ramAvailable),
      ],
    );
  }

  // --- Re-using your existing UI methods below ---

  Widget _buildClockSection() {
    return BlocBuilder<TimeBloc, TimeState>(
      builder: (context, state) {
        return Center(
          child: Column(
            children: [
              Text(
                state.time,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 64,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Courier',
                  letterSpacing: 4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                color: Colors.greenAccent.withOpacity(0.2),
                child: Text(
                  state.date.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontFamily: 'Courier',
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGrid() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatus(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("USER: WANGAI_SAMUEL", 
              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'Courier')),
            Text("STATUS: AUTHORIZED", 
              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'Courier')),
          ],
        ),
        GestureDetector(
          onTap: () => _showTerminal(context),
          child: Icon(Icons.terminal, color: Colors.greenAccent.withOpacity(0.5), size: 20),
        )
      ],
    );
  }

  Widget _infoWidget(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
          color: Colors.greenAccent.withOpacity(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.greenAccent.withOpacity(0.5), fontSize: 8, fontFamily: 'Courier')),
            Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context, AppsBloc appsBloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _dockIcon(Icons.call, () => appsBloc.openAppByName('phone')),
        _dockIcon(Icons.message, () => appsBloc.openAppByName('message')),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsPage()));
          },
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.apps, size: 30, color: Colors.greenAccent),
          ),
        ),
        _dockIcon(Icons.camera_alt, () => appsBloc.openAppByName('camera')),
        _dockIcon(Icons.settings, () => appsBloc.openAppByName('settings')),
      ],
    );
  }

  Widget _dockIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.greenAccent.withOpacity(0.8), size: 28),
      onPressed: onTap,
    );
  }

  void _showTerminal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Terminal",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const TerminalPopup();
      },
    );
  }
}