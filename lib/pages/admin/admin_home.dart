import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Bienvenue sur l'Espace Admin",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
