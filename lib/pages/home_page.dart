import 'package:flutter/material.dart';
import 'package:smart_receipt/pages/settings_page.dart';
import 'package:smart_receipt/theme/app_theme.dart';
import '../biometric_service.dart';
import 'add_expense_page.dart';
import 'overview_page.dart';
import 'stats_page.dart';
import 'package:flutter/services.dart';
import 'dart:ui';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  bool _biometricChecked = false;
  bool _locked = true; //<---- ADD THIS

  final pages = [
    OverviewPage(),
    StatsPage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_biometricChecked) {
        _biometricChecked = true;
        _authenticate();
      }
    });
  }

  Future<void> _authenticate() async {
    setState(() => _locked = true);

    final success = await BiometricService.checkAndAuthenticateOnOpen(context);

    if (success) {
      setState(() => _locked = false);
      return;
    }

    bool retry = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Authentication Required"),
        content: const Text("Biometric authentication is required."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Close App"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Retry"),
          ),
        ],
      ),
    );

    if (retry == true) {
      _authenticate();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index == 1) {
          setState(() => index = 0);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Smart Receipt", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsPage()),
                    );
                  },
                )
              ],
            ),

            body: pages[index],

            floatingActionButton: FloatingActionButton(
              backgroundColor: AppTheme.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddExpensePage()),
                );
              },
            ),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: index,
              onTap: (i) => setState(() => index = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_outline),
                  label: "Reports",
                ),
              ],
            ),
          ),

          // ─────────────────────────────────────────────
          // 🔒 BLUR LOCK SCREEN OVERLAY
          // ─────────────────────────────────────────────
          if (_locked)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock, size: 60, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Unlocking...",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}