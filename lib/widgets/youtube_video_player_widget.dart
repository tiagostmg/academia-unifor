import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    return SizedBox(
      // height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videoUrls.length,
        itemBuilder: (context, index) {
          final videoId = YoutubePlayer.convertUrlToId(_videoUrls[index]);

          if (videoId == null) {
            return const Text("Erro ao carregar o vídeo");
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                ),
                showVideoProgressIndicator: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
