import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart' hide PlayerState;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  File? audioFile;

  Future record() async {
    if (!isRecorderReady) return;

    final Directory appDir = await getApplicationDocumentsDirectory();

    Directory("${appDir.path}/docs/vitalog/audios/").create(recursive: true);
    await recorder.startRecorder(
      toFile:
          "${appDir.path}/docs/vitalog/audios/${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}_${DateTime.now().hour}${DateTime.now().minute}.aac",
    );
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();

    if (path != null) {
      audioFile = File(path);
      setState(() {});
      print("audio_recorder path: $audioFile");
    }
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission is not granted';
    }

    await recorder.openRecorder();

    setState(() {
      isRecorderReady = true;
    });

    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future initAudio() async {
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
    initAudio();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Recording time display
          StreamBuilder(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final recDuration = snapshot.hasData
                  ? snapshot.data!.duration
                  : Duration.zero;

              String twoDigits(int n) => n.toString().padLeft(2);
              final twoDigitMinutes = twoDigits(
                recDuration.inMinutes.remainder(60),
              );
              final twoDigitSecounds = twoDigits(
                recDuration.inSeconds.remainder(60),
              );

              return Text(
                "$twoDigitMinutes : $twoDigitSecounds",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Record/Stop button
          ElevatedButton.icon(
            onPressed: () async {
              if (recorder.isRecording) {
                await stop();
              } else {
                await record();
              }
              setState(() {});
            },
            icon: Icon(recorder.isRecording ? Icons.stop : Icons.mic, size: 28),
            label: Text(
              recorder.isRecording ? 'Stop Recording' : 'Start Recording',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: recorder.isRecording
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Playback controls (only show when audio file exists)
          if (audioFile != null) ...[
            // Audio file info
            const Text(
              'Recording',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Progress slider
            Slider(
              value: position.inSeconds.toDouble(),
              onChanged: (v) async {
                final positionA = Duration(seconds: v.toInt());
                await audioPlayer.seek(positionA);
                await audioPlayer.resume();
              },
              max: duration.inSeconds.toDouble(),
              min: 0,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),

            // Time display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${position.inMinutes.toString().padLeft(2)}:${position.inSeconds.remainder(60).toString().padLeft(2)}",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "${duration.inMinutes.toString().padLeft(2)}:${duration.inSeconds.remainder(60).toString().padLeft(2)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Play/Pause button
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: IconButton(
                iconSize: 36,
                onPressed: () async {
                  await audioPlayer.setSourceDeviceFile(audioFile!.path);
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                  setState(() {});
                },
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
