import 'package:flutter/material.dart';
import 'package:tet_shop/features/shopping/presentation/pages/tet_redesign_page.dart';

class TetShopApp extends StatelessWidget {
  const TetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đi chợ Tết',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC0392B)),
        useMaterial3: true,
      ),
      home: const TetRedesignPage(),
    );
  }
}
