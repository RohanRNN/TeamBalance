import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:team_balance/app/views/settings/post/video_player_widget.dart';
import 'package:team_balance/utils/themes/app_theme.dart';

class PickCamerMedia extends StatefulWidget {
  const PickCamerMedia({super.key});

  @override
  State<PickCamerMedia> createState() => _PickCamerMediaState();
}

class _PickCamerMediaState extends State<PickCamerMedia> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isImage = true;
  XFile? capturedMedia;
  bool isVideo = false;
  bool isVideoRecording = false;
  int timerForRecording = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
    void startTimer() {
    timerForRecording = 0; // Reset timer
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timerForRecording++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel(); // Stop the timer
    setState(() {
      timerForRecording = 0; // Reset timer if needed
    });
  }

  Future<void> _setUpCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(cameras.first, ResolutionPreset.medium);
      });
      cameraController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    var deviceSize = MediaQuery.of(context).size;
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Stack(
      children: [
        Container(
          color: Colors.grey.shade200,
          height: deviceSize.height,
          width: deviceSize.width,
        ),
        //  Center(
        //           child: AspectRatio(
        //             aspectRatio: cameraController!.value.aspectRatio,
        //             child: CameraPreview(cameraController!),
        //           ),
        //         ),
        Padding(
          padding: const EdgeInsets.only(top:100.0),
          child: Container(
            // height: deviceSize.height,
            // width: deviceSize.width,
            child: CameraPreview(cameraController!),
          ),
        ),
        if (capturedMedia != null)
          Positioned.fill(
            child: capturedMediaPreview(),
          ),
        capturedMedia == null
            ? Positioned(
                left: 25,
                right: 25,
                bottom: 50,
                child: Column(
                  children: [
                    Container(
                      width: 70.0,
                      height: 70.0,
                      child: InkWell(
                        onTap: () {
                          isImage ? takePicture() : toggleVideoRecording();
                        },
                        child: Container(
                          width: 70.0,
                          height: 70.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            isVideoRecording ? Icons.stop : isImage ? Icons.camera_alt : Icons.videocam,
                            size: 30.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(                      
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                      decoration: BoxDecoration(
                        color:isImage? Colors.white : const Color.fromARGB(95, 224, 224, 224),
                        borderRadius: BorderRadius.circular(50),
                      ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isImage = true;
                                  });
                                },
                                child: Text(
                                  'Image',
                                  style: isImage ? tbMediaTextSelected() : tbMediaTextNormal(),
                                ),
                              ),
                            ),
                          ),
                          Container(
                      decoration: BoxDecoration(
                        color:isImage?const Color.fromARGB(95, 224, 224, 224): const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(50),
                      ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isImage = false;
                                  });
                                },
                                child: Text(
                                  'Video',
                                  style: isImage ? tbMediaTextNormal() : tbMediaTextSelected(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: Text('This is testing'),
            // )
           isImage ? SizedBox() : isVideoRecording ? Positioned(
              top:75,
              left:10,
              child: Text('Recording : ${formatTime(timerForRecording)}')):SizedBox()
      ],
    );
  }

  Widget capturedMediaPreview() {
    return Stack(
      children: [
        Positioned.fill(
          child: isVideo
              ? VideoPlayerWidget(file: File(capturedMedia!.path))
              : Image.file(
                  File(capturedMedia!.path),
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          bottom: 50,
          left: 25,
          right: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    capturedMedia = null;
                  });
                },
                child: Text('Retake'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(capturedMedia);
                },
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  takePicture() async {
    try {
      await cameraController!.initialize();
      final XFile file = await cameraController!.takePicture();
      setState(() {
        capturedMedia = file;
        isVideo = false;
      });
    } catch (e) {
      print(e);
    }
  }

  toggleVideoRecording() async {
    if (isVideoRecording) {
      stopVideoRecording();
    } else {
      startVideoRecording();
    }
  }

  startVideoRecording() async {
    try {
      await cameraController!.initialize();
      await cameraController!.startVideoRecording();
      startTimer();
      setState(() {
        isVideoRecording = true;
      });

      _timer = Timer(Duration(seconds: 40), () {
        if (isVideoRecording) {
          stopVideoRecording();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  stopVideoRecording() async {
    try {
      final XFile file = await cameraController!.stopVideoRecording();
      _timer?.cancel();
      stopTimer();
      setState(() {
        capturedMedia = file;
        isVideo = true;
        isVideoRecording = false;
      });
    } catch (e) {
      print(e);
    }
  }
}