import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:academia_unifor/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/models/equipment.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 0,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(showNotificationIcon: false),
            body: AdminScreenBody(),
          ),
        ),
      ),
    );
  }
}

class AdminScreenBody extends StatefulWidget {
  const AdminScreenBody({super.key});

  @override
  State<AdminScreenBody> createState() => _AdminScreenBodyState();
}

class _AdminScreenBodyState extends State<AdminScreenBody> {
  int totalUsers = 0;
  int totalEquipments = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bundle = DefaultAssetBundle.of(context);

    final usersJson = await bundle.loadString('assets/mocks/users.json');
    final equipmentJson = await bundle.loadString(
      'assets/mocks/equipment.json',
    );

    final users =
        (jsonDecode(usersJson) as List)
            .map((json) => Users.fromJson(json))
            .where((user) => !user.isAdmin)
            .toList();

    final equipment =
        (jsonDecode(equipmentJson)['gymEquipment'] as List)
            .map((json) => EquipmentCategory.fromJson(json))
            .toList();

    final total = equipment.fold<int>(0, (sum, e) => sum + e.total);

    if (!mounted) return;

    setState(() {
      totalUsers = users.length;
      totalEquipments = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildCard(
                context,
                Icons.logout,
                'Sair',
                '',
                onTap: () => context.go('/'),
              ),
              _buildCard(
                context,
                Icons.home,
                'Ir para o app',
                '',
                onTap: () => context.go('/home'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCard(
                context,
                Icons.people,
                'Total de alunos',
                '$totalUsers',
                onTap: () => context.go('/admin/students'),
              ),
              _buildCard(
                context,
                Icons.fitness_center,
                'Total de aparelhos',
                '$totalEquipments',
                onTap: () => context.go('/admin/equipments'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCard(
                context,
                Icons.description,
                'Ver treinos',
                '$totalUsers',
                onTap: () => context.go('/admin/exercises'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: colorScheme.onSurface),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: colorScheme.onSurface)),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
