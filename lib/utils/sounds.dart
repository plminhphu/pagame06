import 'package:flame_audio/flame_audio.dart';

class Sounds {
  static Future<void> initialize() async {
    await FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'background.mp3',
      'click.wav',
      'seed.wav',
      'coinin.wav',
      'coinout.wav',
      'harvest.wav',
      'inpross.wav',
      'congratulations.wav',
      'failure.wav',
    ]);
  }

  static Future<void> playBackground() async {
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play('background.mp3', volume: 0.4);
  }

  static Future<void> stopBackground() async {
    await FlameAudio.bgm.stop();
  }

  static Future<void> dispose() async {
    await FlameAudio.bgm.dispose();
  }

  static void click() {
    FlameAudio.play('click.wav', volume: .6);
  }

  static void seed() {
    FlameAudio.play('seed.wav', volume: .8);
  }

  static void coinin() {
    FlameAudio.play('coinin.wav', volume: 1);
  }

  static void coinout() {
    FlameAudio.play('coinout.wav', volume: 1);
  }

  static void harvest() {
    FlameAudio.play('harvest.wav', volume: 1);
  }

  static void inpross() {
    FlameAudio.play('inpross.wav', volume: 1);
  }

  static void congratulations() {
    FlameAudio.play('congratulations.wav', volume: 2);
  }

  static void failure() {
    FlameAudio.play('failure.wav', volume: 2);
  }
}
