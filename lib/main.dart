import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/agent_provider.dart';
import 'services/api_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'widgets/app_drawer.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider(
          create: (context) => AgentProvider(
            context.read<ApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Traffic Control Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DashboardScreen(),
          '/map': (context) => const MapScreen(),
        },
      ),
    );
  }
}
