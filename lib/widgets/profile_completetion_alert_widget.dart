import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/screens/profile_screen.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileCompletionAlert extends ConsumerWidget {
  const ProfileCompletionAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    bool isProfileIncomplete(Users? user) {
      if (user == null) return false;
      return user.name.isEmpty || 
             user.phone.isEmpty || 
             user.address.isEmpty || 
             user.birthDate == null;
    }

    if (user == null || !isProfileIncomplete(user)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange[700],
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Complete seu perfil para ter acesso a todos os recursos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Text(
              'COMPLETAR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}