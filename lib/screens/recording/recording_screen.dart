import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/services/recording.dart';
import 'package:tatyanas_app/state/app_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool isRecording = false;
  bool isRecorded = false;

  Stopwatch _stopwatch = Stopwatch();
  Timer _refreshingTimer;
  Timer _recordingTimer;

  RecordingService _recordingService = RecordingService();

  String _helpingMessage;

  String recordedFilePath;

  Future startRecording() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final fileName = "${DateTime.now().toString().replaceAll(RegExp(r'(?:_|[^\w\s]| )+'), '')}.m4a";
    final fullPath = "${documentDirectory.path}/$fileName";
    // recordedFilePath = fullPath;
    recordedFilePath = fileName;
    print(fullPath);
    await _recordingService.record(fullFilePath: fullPath);
    setState(() {
      isRecording = true;
      isRecorded = false;
      _helpingMessage =
          _helpingMessage =
          AppLocalizations.of(context).tapToStopRecording;
    });
    _stopwatch.reset();
    _stopwatch.start();
    recordingTimeOutOccurChecker();
    startRefreshingFrame();
    print("recording start");
  }

  Future stopRecording() async {
    _stopwatch.stop();
    _refreshingTimer.cancel();
    _recordingTimer.cancel();
    setState(() {
      isRecording = false;
      isRecorded = true;
      _helpingMessage =
          AppLocalizations.of(context).tapAgainToRecordANewAudio;
    });
    _recordingService.stopRecording();
    print("stopwatch stopped");
  }

  void startRefreshingFrame() {
    _refreshingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void recordingTimeOutOccurChecker() {
    _recordingTimer = Timer(
      Duration(seconds: 30),
      () {
        stopRecording();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startRefreshingFrame();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appState = Provider.of<AppState>(context, listen: false);

    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        floatingActionButton: isRecorded
            ? FloatingActionButton(
                onPressed: () {
                  appState.navigatorKey.currentState.pop(recordedFilePath);
                },
                child: Icon(Icons.check),
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey[800],
              )
            : SizedBox(),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (!isRecording) {
                    startRecording();
                  } else {
                    stopRecording();
                  }
                },
                child: Container(
                  width: size.width * 0.4,
                  height: size.width * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: !isRecording
                      ? Center(
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: size.width * 0.2,
                          ),
                        )
                      : Center(
                          child: Text(
                            _stopwatch.elapsed.inSeconds.toString(),
                            style: TextStyle(
                                fontSize: size.width * 0.15, color: Colors.white),
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              isRecorded
                  ? Text(
                AppLocalizations.of(context).audioRecorded,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 24,
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: isRecorded ? 8 : 0,
              ),
              Text(
                _helpingMessage ?? AppLocalizations.of(context).tapRecordingButtonToStartRecording,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
