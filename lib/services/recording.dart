
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class RecordingService {
  FlutterSoundRecorder _flutterSoundRecorder = FlutterSoundRecorder();

  static final RecordingService _recordingService = RecordingService
      ._internal();

  factory RecordingService(){
    return _recordingService;
  }

  RecordingService._internal();


  Future record({@required String fullFilePath}) async {
    final isGranted = await Permission.microphone.request();
    if(isGranted.isGranted){
      // await _flutterSoundRecorder.openAudioSession();
      // await _flutterSoundRecorder.startRecorder(toFile: "${DateTime.now().toString()}.mp3");
      // _flutterSoundRecorder.onProgress.listen((event) {
      //   print(event.duration.toString());
      //   print(_flutterSoundRecorder.recorderState.toString());
      // });
      await Record.start(path: fullFilePath,);

    }else{
      print("Permission not granted");
    }
  }

  Future<String> stopRecording()async{
    // final url = await _flutterSoundRecorder.stopRecorder();
    // await _flutterSoundRecorder.closeAudioSession();
    final isRecording = await Record.isRecording();
    assert(isRecording, "No recording is in progress");
    if(isRecording){
      await Record.stop();
    }
    return  "";
  }
}
