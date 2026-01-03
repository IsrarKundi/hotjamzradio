import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum PlayerState { idle, loading, playing, paused, error }

class RadioPlayerController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.idle;
  double _volume = 0.7;
  String? _errorMessage;
  bool _isBuffering = false;

  final String radioUrl =
      "https://das-edge15-live365-dal02.cdnstream.com/a37600";

  RadioPlayerController() {
    _initPlayer();
  }

  // Getters
  PlayerState get playerState => _playerState;
  double get volume => _volume;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get isBuffering => _isBuffering;
  AudioPlayer get audioPlayer => _audioPlayer;

  void _initPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;

      if (state.processingState == ProcessingState.ready) {
        if (state.playing) {
          _playerState = PlayerState.playing;
        } else {
          _playerState = PlayerState.paused;
        }
      } else if (state.processingState == ProcessingState.completed) {
        _playerState = PlayerState.paused;
      }
      notifyListeners();
    });

    // Listen to errors
    _audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        debugPrint('Radio player error: $e');
        _errorMessage = 'Failed to load radio stream';
        _playerState = PlayerState.error;
        notifyListeners();
      },
    );
  }

  Future<void> initialize() async {
    try {
      _playerState = PlayerState.loading;
      _errorMessage = null;
      notifyListeners();

      await _audioPlayer.setUrl(radioUrl);
      debugPrint('Radio stream initialized successfully');
    } catch (e) {
      debugPrint('Error initializing radio: $e');
      _errorMessage = 'Failed to initialize radio stream';
      _playerState = PlayerState.error;
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      if (_playerState == PlayerState.idle) {
        await initialize();
      }
      await _audioPlayer.play();
      _playerState = PlayerState.playing;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing radio: $e');
      _errorMessage = 'Failed to play radio stream';
      _playerState = PlayerState.error;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _playerState = PlayerState.paused;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing radio: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  void increaseVolume() {
    setVolume(_volume + 0.1);
  }

  void decreaseVolume() {
    setVolume(_volume - 0.1);
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _playerState = PlayerState.idle;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping radio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
