import 'package:angkutin/provider/auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
        final authProvider = Provider.of<AuthenticationProvider>(context);
        // Handle potential null user
    final user = authProvider.currentUser;

    return Scaffold(
      body: Column(
        children: [
         Text(user!.displayName!)
        ],
      ),
    );
  }
}