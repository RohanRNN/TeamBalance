import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_trimmer/video_trimmer.dart';
// import 'package:video_trimmer/video_trimmer.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  VideoPlayerWidget({required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {}); // Update the state once video is initialized
        _controller.play(); // Auto-play video
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey[300]!,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: VideoPlayerControls(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;

  VideoPlayerControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
      onPressed: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
    );
  }
}






