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
        backgroundColor: Colors.black,
        title: const Text("Installed Apps", style: TextStyle(color: Colors.greenAccent)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: BlocBuilder<AppsBloc, AppsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  style: const TextStyle(color: Colors.greenAccent),
                  decoration: InputDecoration(
                    hintText: 'Search apps...',
                    hintStyle: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: context.read<AppsBloc>().search,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = state.filteredApps[index];
                    return ListTile(
                      onTap: () => context.read<AppsBloc>().openApp(app.package),
                      leading: app.icon != null
                          ? Image.memory(app.icon!, width: 40, height: 40)
                          : const Icon(Icons.apps, color: Colors.greenAccent),
                      title: Text(
                        app.name,
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
                      ),
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
