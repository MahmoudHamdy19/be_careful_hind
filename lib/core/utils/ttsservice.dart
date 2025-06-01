import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> init() async {
    await _flutterTts.setLanguage("ar-SA");      // Arabic - Saudi Arabia
    await _flutterTts.setPitch(1.0);             // Normal pitch
    await _flutterTts.setSpeechRate(0.5);        // Moderate speed
    await _flutterTts.setVolume(1.0);            // Full volume

    // Optionally, choose a female voice if available
    List<dynamic> voices = await _flutterTts.getVoices;
    for (var voice in voices) {
      if (voice is Map && voice['name'] != null && voice['name'].toString().contains('female')) {
        await _flutterTts.setVoice({
          'name': voice['name'],
          'locale': voice['locale']
        });
        break;
      }
    }
  }

  static Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> setLanguage(String langCode) async {
    await _flutterTts.setLanguage(langCode);
  }

  static Future<void> setRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  static Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  static Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }
}
