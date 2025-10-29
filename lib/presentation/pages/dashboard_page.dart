import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/repositories/sensor_repository_impl.dart';
import '../../data/datasources/server/http_server_manager.dart';
import '../pages/data_page.dart';
import '../pages/server_info_page.dart';
import '../pages/config_page.dart';

class DashboardPage extends StatefulWidget {
  final HttpServerManager server;
  final SensorRepositoryImpl sensorRepo;

  const DashboardPage({
    super.key,
    required this.server,
    required this.sensorRepo,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late StreamController<SensorDataSnapshot> _sensorStreamController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _sensorStreamController = StreamController<SensorDataSnapshot>.broadcast();

    // Initial load
    _fetchSensorData();

    // Auto-refresh every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchSensorData();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollingTimer?.cancel();
    _sensorStreamController.close();
    super.dispose();
  }

  Future<void> _fetchSensorData() async {
    final data = await widget.sensorRepo.getLatestSensorData();

    if (!_sensorStreamController.isClosed) {
      _sensorStreamController.add(
        SensorDataSnapshot(
          temperature: data?.temperature,
          humidity: data?.humidity,
          statusTemperature: data?.statusTemperature,
          statusHumidity: data?.statusHumidity,
          timestamp: data?.timestamp,
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    // Add loading state
    _sensorStreamController.add(
      SensorDataSnapshot(
        temperature: null,
        humidity: null,
        statusTemperature: null,
        statusHumidity: null,
        timestamp: null,
        isLoading: true,
      ),
    );

    await _fetchSensorData();
  }

  String _formatTimestamp(DateTime timestamp) {
    try {
      final now = DateTime.now();
      final diff = now.difference(timestamp);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return timestamp.toIso8601String();
    }
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 20) return Colors.blue;
    if (temp < 26) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double hum) {
    if (hum < 30) return Colors.orange;
    if (hum < 60) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('IoT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConfigPage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<SensorDataSnapshot>(
        stream: _sensorStreamController.stream,
        initialData: SensorDataSnapshot(
          temperature: null,
          humidity: null,
          statusTemperature: null,
          statusHumidity: null,
          timestamp: null,
          isLoading: true,
        ),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final isLoading = data?.isLoading ?? true;
          final temp = data?.temperature;
          final hum = data?.humidity;
          final tempStatus = data?.statusTemperature;
          final humStatus = data?.statusHumidity;
          final timestamp = data?.timestamp;

          String status = 'Loading...';
          if (!isLoading) {
            if (timestamp != null) {
              status = _formatTimestamp(timestamp);
            } else {
              status = 'No data available';
            }
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Server Status Card
                  _buildServerStatusCard(status),

                  const SizedBox(height: 20),

                  // Sensor Data Section
                  Row(
                    children: [
                      const Text(
                        'Sensor Readings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Auto-refresh indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              size: 14,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (temp != null && hum != null)
                    Column(
                      children: [
                        _buildSensorCard(
                          title: 'Temperature',
                          value: temp.toStringAsFixed(1),
                          unit: '°C',
                          icon: Icons.thermostat_rounded,
                          color: _getTemperatureColor(temp),
                          progress: (temp / 50).clamp(0.0, 1.0),
                          status: tempStatus,
                        ),
                        const SizedBox(height: 12),
                        _buildSensorCard(
                          title: 'Humidity',
                          value: hum.toStringAsFixed(1),
                          unit: '%',
                          icon: Icons.water_drop_rounded,
                          color: _getHumidityColor(hum),
                          progress: (hum / 100).clamp(0.0, 1.0),
                          status: humStatus,
                        ),
                      ],
                    )
                  else if (!isLoading)
                    _buildEmptyState()
                  else
                    _buildLoadingCards(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Server Info',
                          icon: Icons.dns_rounded,
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServerInfoPage(server: widget.server),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          title: 'History',
                          icon: Icons.history_rounded,
                          color: Colors.purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DataPage(sensorRepo: widget.sensorRepo),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Configuration',
                          icon: Icons.tune_rounded,
                          color: Colors.teal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ConfigPage()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          title: 'Refresh',
                          icon: Icons.refresh_rounded,
                          color: Colors.orange,
                          onTap: _refreshData,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServerStatusCard(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
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
            child: FadeTransition(
              opacity: _pulseController,
              child: const Icon(
                Icons.wifi_tethering_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Server Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.server.serverInfo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
    String? status,
  }) {
    // Determine status color and icon
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (status != null) {
      if (status.toLowerCase() == 'ideal' || status.toLowerCase() == 'normal') {
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else if (status.toLowerCase() == 'warning' ||
          status.toLowerCase() == 'caution') {
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
      } else if (status.toLowerCase() == 'critical' ||
          status.toLowerCase() == 'danger') {
        statusColor = Colors.red;
        statusIcon = Icons.error;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.sensors_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Sensor Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or wait for incoming data',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        _buildLoadingCard(),
        const SizedBox(height: 12),
        _buildLoadingCard(),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for sensor snapshot
class SensorDataSnapshot {
  final double? temperature;
  final double? humidity;
  final String? statusTemperature;
  final String? statusHumidity;
  final DateTime? timestamp;
  final bool isLoading;

  const SensorDataSnapshot({
    required this.temperature,
    required this.humidity,
    required this.statusTemperature,
    required this.statusHumidity,
    required this.timestamp,
    required this.isLoading,
  });
}
