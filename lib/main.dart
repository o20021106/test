import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'native_add.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RecorderPage(),
    );
  }
}

class RecorderPage extends StatefulWidget {
  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  int _recordingCount = 0;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
    } else {
      if (await _audioRecorder.hasPermission()) {
        _filePath = await getApplicationDocumentsDirectory().then((value) =>
            '${value.path}/here_is_your_recording_$_recordingCount.wav');
        print(_filePath);
        _recordingCount++;

        // Delete the existing file if it exists
        final file = File(_filePath!);
        if (file.existsSync()) {
          print('Deleting existing file');
          await file.delete();
        }

        await _audioRecorder.start(const RecordConfig(), path: _filePath!);
      }
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      print("Playing file: $_filePath");
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(_filePath!));
      setState(() {
        _isPlaying = true;
      });
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
        });
      });
    }
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Voice Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPlaying ? _stopPlaying : _playRecording,
              child: Text(_isPlaying ? 'Stop Playing' : 'Play Recording'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
