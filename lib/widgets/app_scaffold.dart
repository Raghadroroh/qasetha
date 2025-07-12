import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_controls.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showControls;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            body,
            if (showControls)
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: const AppControls(),
                ),
              ),
          ],
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}