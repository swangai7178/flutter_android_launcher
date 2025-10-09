import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/pages/apps_pages.dart';
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
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset('assets/icons/icon.png', width: 300),
            ),
          ),
          BlocBuilder<TimeBloc, TimeState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    state.time,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.date,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 45,
                          icon: const Icon(Icons.sim_card, color: Colors.greenAccent),
                          onPressed: () => appsBloc.openAppByName('sim'),
                        ),
                        IconButton(
                          iconSize: 45,
                          icon: const Icon(Icons.call, color: Colors.greenAccent),
                          onPressed: () => appsBloc.openAppByName('phone'),
                        ),
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
                            child: const Icon(Icons.apps, size: 35, color: Colors.greenAccent),
                          ),
                        ),
                        IconButton(
                          iconSize: 45,
                          icon: const Icon(Icons.message, color: Colors.greenAccent),
                          onPressed: () => appsBloc.openAppByName('message'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
