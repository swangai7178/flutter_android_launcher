import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/pages/apps_pages.dart';
import 'package:launcher/utlis/terminalpopup_widget.dart';
import '../blocs/time_bloc.dart';
import '../blocs/apps_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appsBloc = context.read<AppsBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- LAYER 1: THE BACKGROUND SYSTEM ---
          // You can swap this out with an Image.asset if the user picks a wallpaper
          _buildBackgroundGrid(),

          // --- LAYER 2: DECORATIVE LOGO ---
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/icons/icon.png', width: 400),
            ),
          ),

          // --- LAYER 3: MAIN UI CONTENT ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderStatus(context),
                  const Spacer(),
                  
                  // Central Clock Section
                  BlocBuilder<TimeBloc, TimeState>(
                    builder: (context, state) {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              state.time,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 64,
                                fontWeight: FontWeight.w100, // Thin font looks more modern
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
                  ),

                  const Spacer(),

                  // New "System Widgets" Row
                  _buildSystemWidgets(),

                  const SizedBox(height: 40),

                  // Bottom Navigation
                  _buildBottomDock(context, appsBloc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A subtle grid pattern to give that 'Dev' look
  Widget _buildBackgroundGrid() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'), // Replace with local asset for offline
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

  Widget _buildSystemWidgets() {
    return Row(
      children: [
        _infoWidget("BATTERY", "88%"),
        const SizedBox(width: 15),
        _infoWidget("TEMP", "32°C"),
        const SizedBox(width: 15),
        _infoWidget("RAM", "2.4GB"),
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
        
        // Main App Drawer Button
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