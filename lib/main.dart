import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traffic_control_dashboard/services/api_services.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(baseUrl: 'http://localhost:5000'),
      child: MaterialApp(
        title: 'Traffic Light Control Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF4F6F9),
          fontFamily: 'Segoe UI',
          cardTheme: CardTheme(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const MainLayout(),
      ),
    );
  }
}