// sound_player.dart
import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playGoodSound() async {
    await _player.play(AssetSource('sounds/good.mp3'));
  }

  static Future<void> playMissedSound() async {
    await _player.play(AssetSource('sounds/missed.mp3'));
  }

  static void dispose() {
    _player.dispose();
  }
}
