import 'package:flutter/material.dart';
import '../../data/datasources/local/config_local_data_source.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../widgets/ideal_config_form.dart';

class ConfigPage extends StatelessWidget {
  final ConfigRepositoryImpl configRepo = ConfigRepositoryImpl(
    ConfigLocalDataSource(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ideal Configuration')),
      body: IdealConfigForm(configRepo: configRepo),
    );
  }
}
