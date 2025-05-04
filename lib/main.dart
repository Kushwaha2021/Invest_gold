import 'package:flutter/material.dart';
import 'package:invest_gold/view_model/gold_rate_view_model.dart';
import 'package:provider/provider.dart';

import 'Home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GoldRateViewModel()..fetchGoldRates(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Price Tracker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
