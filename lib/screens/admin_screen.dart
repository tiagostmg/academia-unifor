import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showNotificationIcon: false),
      body: const Center(child: Text('Bem-vindo, Admin!')),
    );
  }
}
