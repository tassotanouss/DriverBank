import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/currency_scope.dart';
import '../../home/pages/home_page.dart';
import '../pages/firebase_setup_required_page.dart';
import '../pages/login_page.dart';
import '../services/firebase_bootstrap.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.bootstrap,
    required this.currencyController,
  });

  final FirebaseBootstrapResult bootstrap;
  final CurrencyController currencyController;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    if (!widget.bootstrap.isConfigured) {
      return;
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      widget.currencyController.reloadForCurrentUser();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.bootstrap.isConfigured) {
      return FirebaseSetupRequiredPage(
        errorMessage: widget.bootstrap.errorMessage,
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
