import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

/// Example usage of Firebase Analytics integration
/// This demonstrates how to use the AnalyticsService throughout the app
class AnalyticsUsageExample extends StatelessWidget {
  const AnalyticsUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Analytics Integration Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => _logCustomEvent(),
              child: const Text('Log Custom Event'),
            ),
            
            ElevatedButton(
              onPressed: () => _logLoginEvent(),
              child: const Text('Log Login Event'),
            ),
            
            ElevatedButton(
              onPressed: () => _logGuestModeEvent(),
              child: const Text('Log Guest Mode Event'),
            ),
            
            ElevatedButton(
              onPressed: () => _setUserProperty(),
              child: const Text('Set User Property'),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logScreenView(),
              child: const Text('Log Screen View Manually'),
            ),
            
            const SizedBox(height: 10),
            const Text(
              'Screen tracking is also handled automatically via GoRouter observer',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logCustomEvent() async {
    await AnalyticsService.logEvent(
      name: 'button_clicked',
      parameters: {
        'button_name': 'custom_event_example',
        'screen': 'analytics_example',
      },
    );
  }

  Future<void> _logLoginEvent() async {
    await AnalyticsService.logLogin(method: 'email');
  }

  Future<void> _logGuestModeEvent() async {
    await AnalyticsService.logGuestModeEnter();
  }

  Future<void> _setUserProperty() async {
    await AnalyticsService.setUserProperty(
      name: 'user_type',
      value: 'premium',
    );
  }

  Future<void> _logScreenView() async {
    await AnalyticsService.logScreenView(
      screenName: 'analytics_example_screen',
      screenClass: 'AnalyticsUsageExample',
    );
  }
}