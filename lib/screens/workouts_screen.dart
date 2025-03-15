import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1, // Índice correspondente ao botão "Treinos"
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(),
            body: const WorkoutsBody(),
          ),
        ),
      ),
    );
  }
}

class WorkoutsBody extends StatelessWidget {
  const WorkoutsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const YoutubeVideoPlayer();
  }
}

class YoutubeVideoPlayer extends StatefulWidget {
  const YoutubeVideoPlayer({super.key});

  @override
  WorkoutsBodyState createState() => WorkoutsBodyState();
}

class WorkoutsBodyState extends State<YoutubeVideoPlayer> {
  final List<String> _videoUrls = [
    'https://www.youtube.com/watch?v=XtdZtMfRQ6A&list=PLVfDJ3j76CinxIhBRpQgx93em_P9nWzmc&index=29',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videoUrls.length,
      itemBuilder: (context, index) {
        final videoId = YoutubePlayer.convertUrlToId(_videoUrls[index])!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              8,
            ), // Adiciona bordas arredondadas
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: false, // Desativa autoplay
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
            ),
          ),
        );
      },
    );
  }
}
