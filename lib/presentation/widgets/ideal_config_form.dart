import 'package:flutter/material.dart';
import '../../data/repositories/config_repository_impl.dart';

class IdealConfigForm extends StatefulWidget {
  final ConfigRepositoryImpl configRepo;
  const IdealConfigForm({super.key, required this.configRepo});

  @override
  State<IdealConfigForm> createState() => _IdealConfigFormState();
}

class _IdealConfigFormState extends State<IdealConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late double minTemp, maxTemp, minHum, maxHum;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await widget.configRepo.getIdealConfig();
    setState(() {
      minTemp = config.minTemp;
      maxTemp = config.maxTemp;
      minHum = config.minHum;
      maxHum = config.maxHum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Temperature
            TextFormField(
              initialValue: minTemp.toString(),
              decoration: const InputDecoration(
                labelText: 'Min Temperature (°C)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
              onSaved: (v) => minTemp = double.parse(v!),
            ),
            TextFormField(
              initialValue: maxTemp.toString(),
              decoration: const InputDecoration(
                labelText: 'Max Temperature (°C)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
              onSaved: (v) => maxTemp = double.parse(v!),
            ),

            // Humidity
            TextFormField(
              initialValue: minHum.toString(),
              decoration: const InputDecoration(labelText: 'Min Humidity (%)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
              onSaved: (v) => minHum = double.parse(v!),
            ),
            TextFormField(
              initialValue: maxHum.toString(),
              decoration: const InputDecoration(labelText: 'Max Humidity (%)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
              onSaved: (v) => maxHum = double.parse(v!),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.configRepo.saveIdealConfig(
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    minHum: minHum,
                    maxHum: maxHum,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration saved!')),
                  );
                }
              },
              child: const Text('Save Ideal Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
