import 'package:flutter/material.dart';

class TempHumidityCard extends StatelessWidget {
  final double? temperature;
  final double? humidity;
  final String status;

  const TempHumidityCard({
    super.key,
    this.temperature,
    this.humidity,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (temperature != null)
              Text(
                '🌡️ ${temperature!.toStringAsFixed(1)} °C',
                style: const TextStyle(fontSize: 24),
              ),
            if (humidity != null)
              Text(
                '💧 ${humidity!.toStringAsFixed(1)} %',
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 10),
            Text(status, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
