import 'package:flutter/material.dart';

class TerminalPopup extends StatefulWidget {
  const TerminalPopup({super.key});

  @override
  State<TerminalPopup> createState() => _TerminalPopupState();
}

class _TerminalPopupState extends State<TerminalPopup> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _logs = [
    "WS_OS [Version 1.0.42]",
    "AUTHENTICATING USER: WANGAI_SAMUEL...",
    "ACCESS_GRANTED.",
    "Type 'HELP' for available commands.",
    ""
  ];

  void _handleCommand(String input) {
    String command = input.trim().toUpperCase();
    setState(() {
      _logs.add("> $input");
      if (command == "HELP") {
        _logs.add("AVAILABLE: CLEAR, SYS_INFO, NEOFETCH, EXIT");
      } else if (command == "NEOFETCH") {
        _logs.addAll([
          " OS: WS-Launcher 2026",
          " KERNEL: Flutter-Dart-3.x",
          " SHELL: Zsh-Style",
          " THEME: Hacker-Green-Accent",
        ]);
      } else if (command == "SYS_INFO") {
        _logs.add("CPU: 8-CORE | RAM: 2.4GB FREE | DISK: OK");
      } else if (command == "CLEAR") {
        _logs.clear();
      } else if (command == "EXIT") {
        Navigator.pop(context);
      } else {
        _logs.add("COMMAND_NOT_FOUND: $command");
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 1),
            color: Colors.black,
          ),
          child: Column(
            children: [
              // Terminal Header
              Container(
                color: Colors.greenAccent.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TERM_SESSION_01", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'Courier')),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.greenAccent, size: 16),
                    )
                  ],
                ),
              ),
              // Logs Area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _logs.length,
                  itemBuilder: (context, i) => Text(
                    _logs[i],
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 13),
                  ),
                ),
              ),
              // Input Area
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text("> ", style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        cursorColor: Colors.greenAccent,
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
                        decoration: const InputDecoration(border: InputBorder.none),
                        onSubmitted: _handleCommand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}