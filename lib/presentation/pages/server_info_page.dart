import 'package:flutter/material.dart';
import '../../data/datasources/server/http_server_manager.dart';

class ServerInfoPage extends StatelessWidget {
  final HttpServerManager server;
  const ServerInfoPage({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your device is running an HTTP server.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Access URL: ${server.serverInfo}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Endpoints:'),
            const Text(
              'POST /sensor → { "temperature": 25.5, "humidity": 60.0 }',
            ),
            const Text('GET /ideal → returns ideal config'),
          ],
        ),
      ),
    );
  }
}
