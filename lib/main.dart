import 'package:flutter/material.dart';
import 'features/map/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OfflineGpsApp());
}

class OfflineGpsApp extends StatelessWidget {
  const OfflineGpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Offline GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MapScreen(),
    );
  }
}
