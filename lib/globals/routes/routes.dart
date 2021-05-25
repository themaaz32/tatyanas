import 'package:tatyanas_app/screens/config/config_screen.dart';
import 'package:tatyanas_app/screens/crop/crop_image.dart';
import 'package:tatyanas_app/screens/home/home_screen.dart';
import 'package:tatyanas_app/screens/recording/recording_screen.dart';

class AppRoutes {
  static final home = "/home";
  static final config = "/config";
  static final recording = "/recording";
  static final crop = "/crop_image";


  static final routes = {
    home: (context) => HomeScreen(),
    config: (context) => ConfigScreen(),
    recording: (context) => RecordingScreen(),
    // crop: (context) => CropImageScreen(path),
  };
}
