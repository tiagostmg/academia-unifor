import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/screens/edit_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/assets/gemini_logo.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 0, 
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(),
            body: const HomeBody(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              tooltip: 'Abrir chat',
              child: SvgPicture.string(
                geminiLogoSVG,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  bool _hasMissingFields(Users? user) {
    if (user == null) return true;
    
    return user.name.isEmpty || 
           user.email.isEmpty || 
           user.phone.isEmpty || 
           user.address.isEmpty || 
           user.birthDate == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final hasMissingFields = _hasMissingFields(user);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const CarouselWidget(),
          const SizedBox(height: 15),
          const ScheduleWidget(),
          if (hasMissingFields) ...[
            const SizedBox(height: 15),
            _buildMissingFieldsCard(context, user!),
          ],
          const SizedBox(height: 10),
          const ContactWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMissingFieldsCard(BuildContext context, Users user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perfil Incompleto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu perfil está faltando algumas informações importantes. ',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: user),
                      ),
                    );
                  },
                  child: const Text('Completar Perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}