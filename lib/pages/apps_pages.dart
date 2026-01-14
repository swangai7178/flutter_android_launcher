import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/apps_bloc.dart';

class AppsPage extends StatelessWidget {
  const AppsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          "SYSTEM_APPS.EXE",
          style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: BlocBuilder<AppsBloc, AppsState>(
        builder: (context, state) {
          // 1. Handle Loading State
          if (state.status == AppStatus.loading && state.apps.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          // 2. Handle Failure State
          if (state.status == AppStatus.failure && state.apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 10),
                  const Text("CRITICAL_ERROR: FAILED TO LOAD APPS", 
                      style: TextStyle(color: Colors.redAccent, fontFamily: 'Courier')),
                  TextButton(
                    onPressed: () => context.read<AppsBloc>().loadApps(),
                    child: const Text("RETRY_SEQUENCE", style: TextStyle(color: Colors.greenAccent)),
                  )
                ],
              ),
            );
          }

          // 3. Main Success UI
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
                  cursorColor: Colors.greenAccent,
                  decoration: InputDecoration(
                    hintText: 'FILTER_BY_NAME...',
                    hintStyle: TextStyle(color: Colors.greenAccent.withOpacity(0.5), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                    filled: true,
                    fillColor: Colors.greenAccent.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
                      borderRadius: BorderRadius.circular(4), // Square look for hacker aesthetic
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: (value) => context.read<AppsBloc>().search(value),
                ),
              ),
              
              // App List
              Expanded(
                child: state.filteredApps.isEmpty 
                  ? const Center(child: Text("NO_MATCHES_FOUND", style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: state.filteredApps.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.greenAccent.withOpacity(0.1),
                        height: 1,
                        indent: 70,
                      ),
                      itemBuilder: (context, index) {
                        final app = state.filteredApps[index];
                        
                        return ListTile(
                          onTap: () => context.read<AppsBloc>().openApp(app.package),
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: app.iconPath != null
                                  ? Image.file(
                                      File(app.iconPath!),
                                      fit: BoxFit.cover,
                                      // Error builder in case file is corrupted
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.broken_image, color: Colors.greenAccent),
                                    )
                                  : const Icon(Icons.apps, color: Colors.greenAccent),
                            ),
                          ),
                          title: Text(
                            app.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.greenAccent, 
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            app.package,
                            style: TextStyle(
                              color: Colors.greenAccent.withOpacity(0.5), 
                              fontSize: 10,
                              fontFamily: 'Courier',
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 18),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}