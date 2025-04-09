import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/screens.dart';
import 'package:academia_unifor/assets/gemini_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 0, // Índice correspondente ao botão "Início"
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

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const CarouselWidget(),
          const SizedBox(height: 15),
          const ScheduleWidget(),
          const SizedBox(height: 10),
          const ContactWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
