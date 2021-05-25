
import 'package:flutter_sound/public/flutter_sound_player.dart';

class SoundPlayerService {
  FlutterSoundPlayer _flutterSoundPlayer = FlutterSoundPlayer();

  static final SoundPlayerService _playerService = SoundPlayerService
      ._internal();

  factory SoundPlayerService(){
    return _playerService;
  }

  SoundPlayerService._internal();


  Future playAudio(String filePath) async {
    await _flutterSoundPlayer.openAudioSession();
    await _flutterSoundPlayer.startPlayer(fromURI: filePath);
  }

  Future stopAudio()async{
    await _flutterSoundPlayer.stopPlayer();
    await _flutterSoundPlayer.closeAudioSession();
  }
}
