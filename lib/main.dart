import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/pages/homepage.dart';
import 'blocs/time_bloc.dart';
import 'blocs/apps_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
Future <void> main()async  {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(const WSLauncher());
}

class WSLauncher extends StatelessWidget {
  const WSLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TimeBloc()),
        BlocProvider(create: (_) => AppsBloc()), // loads apps immediately
      ],
      child: MaterialApp(
        title: 'WS Launcher',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.greenAccent,
        ),
        home: const HomePage(),
      ),
    );
  }
}
