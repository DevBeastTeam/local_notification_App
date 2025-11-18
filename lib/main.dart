import 'package:flutter/material.dart';
import 'package:notification/notificationservice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Local Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Press the buttons below to test notifications',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.instance.showNotification(
                  id: 1,
                  title: 'Simple Notification',
                  body: 'This is a simple test notification!',
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Show Simple Notification'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.instance.showBigTextNotification(
                  id: 2,
                  title: 'Big Text Example',
                  body: 'Tap to expand!',
                  bigText:
                      'This is an example of a long notification body text. It will appear expanded, similar to what you see in YouTube tutorials!',
                );
              },
              icon: const Icon(Icons.text_fields),
              label: const Text('Show Big Text Notification'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final scheduleTime = DateTime.now().add(
                  const Duration(seconds: 5),
                );
                NotificationService.instance.scheduleNotification(
                  id: 3,
                  title: 'Scheduled Notification',
                  body: 'This notification appeared 5 seconds later!',
                  scheduledDate: scheduleTime,
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Show Scheduled Notification (5s)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.instance.cancelAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cancelled!')),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
