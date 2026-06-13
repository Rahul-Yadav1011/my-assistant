import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _stt = SpeechToText();
  bool _ready = false;

  bool get isListening => _stt.isListening;
  bool get isReady => _ready;

  Future<bool> init() async {
    if (_ready) return true;
    if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
    }
    _ready = await _stt.initialize(
      onError: (e) {},
      onStatus: (_) {},
    );
    return _ready;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stop() async {
    if (_stt.isListening) await _stt.stop();
  }
}
