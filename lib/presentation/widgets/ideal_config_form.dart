// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/config_repository_impl.dart';

class IdealConfigForm extends StatefulWidget {
  final ConfigRepositoryImpl configRepo;
  const IdealConfigForm({super.key, required this.configRepo});

  @override
  State<IdealConfigForm> createState() => _IdealConfigFormState();
}

class _IdealConfigFormState extends State<IdealConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumController;
  late TextEditingController _maxHumController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _minTempController = TextEditingController();
    _maxTempController = TextEditingController();
    _minHumController = TextEditingController();
    _maxHumController = TextEditingController();
    _loadConfig();
  }

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumController.dispose();
    _maxHumController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);

    final config = await widget.configRepo.getIdealConfig();

    if (mounted) {
      setState(() {
        _minTempController.text = config.minTemp.toString();
        _maxTempController.text = config.maxTemp.toString();
        _minHumController.text = config.minHum.toString();
        _maxHumController.text = config.maxHum.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    final minTemp = double.parse(_minTempController.text);
    final maxTemp = double.parse(_maxTempController.text);
    final minHum = double.parse(_minHumController.text);
    final maxHum = double.parse(_maxHumController.text);

    // Validation logic
    if (minTemp >= maxTemp) {
      _showErrorSnackBar('Min temperature must be less than max temperature');
      return;
    }
    if (minHum >= maxHum) {
      _showErrorSnackBar('Min humidity must be less than max humidity');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.configRepo.saveIdealConfig(
        minTemp: minTemp,
        maxTemp: maxTemp,
        minHum: minHum,
        maxHum: maxHum,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        _showSuccessSnackBar('Configuration saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar('Failed to save configuration');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[600]!, Colors.teal[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ideal Configuration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Set your preferred environmental ranges',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Temperature Section
            _buildSectionHeader(
              icon: Icons.thermostat_rounded,
              title: 'Temperature Range',
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minTempController,
                    label: 'Minimum',
                    suffix: '°C',
                    icon: Icons.arrow_downward_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _maxTempController,
                    label: 'Maximum',
                    suffix: '°C',
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Humidity Section
            _buildSectionHeader(
              icon: Icons.water_drop_rounded,
              title: 'Humidity Range',
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minHumController,
                    label: 'Minimum',
                    suffix: '%',
                    icon: Icons.arrow_downward_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _maxHumController,
                    label: 'Maximum',
                    suffix: '%',
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These values will be used to determine if your environment is within ideal conditions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Save Configuration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Reset to Defaults (Optional)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _minTempController.text = '20.0';
                    _maxTempController.text = '26.0';
                    _minHumController.text = '40.0';
                    _maxHumController.text = '60.0';
                  });
                },
                icon: Icon(
                  Icons.restore_rounded,
                  size: 18,
                  color: Colors.grey[600],
                ),
                label: Text(
                  'Reset to Defaults',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          suffixStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          prefixIcon: Icon(icon, color: color, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          final number = double.tryParse(value);
          if (number == null) {
            return 'Invalid number';
          }
          return null;
        },
      ),
    );
  }
}
