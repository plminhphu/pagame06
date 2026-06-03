import 'package:flame_audio/flame_audio.dart';

class Sounds {
  static Future<void> initialize() async {
    await FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'background.m4a',
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
    await FlameAudio.bgm.play('background.m4a', volume: 0.5);
  }

  static Future<void> stopBackground() async {
    await FlameAudio.bgm.stop();
  }

  static Future<void> dispose() async {
    await FlameAudio.bgm.dispose();
  }

  static void click() {
    FlameAudio.play('click.wav', volume: .4);
  }

  static void seed() {
    FlameAudio.play('seed.wav', volume: .6);
  }

  static void coinin() {
    FlameAudio.play('coinin.wav', volume: .8);
  }

  static void coinout() {
    FlameAudio.play('coinout.wav', volume: .8);
  }

  static void harvest() {
    FlameAudio.play('harvest.wav', volume: 1);
  }

  static void inpross() {
    FlameAudio.play('inpross.wav', volume: 1);
  }

  static void congratulations() async {
    FlameAudio.bgm.pause();
    await FlameAudio.play('congratulations.wav', volume: 1);
    await Future.delayed(const Duration(seconds: 2));
    FlameAudio.bgm.resume();
  }

  static void failure() async {
    FlameAudio.bgm.pause();
    await FlameAudio.play('failure.wav', volume: 1);
    FlameAudio.bgm.resume();
  }
}
