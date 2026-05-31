import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pagame06/providers/service.dart';
import 'package:pagame06/widget/icon.dart';

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
    await FlameAudio.bgm.play('background.mp3', volume: 0.2);
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
    FlameAudio.play('coinin.wav', volume: .6);
  }

  static void coinout() {
    FlameAudio.play('coinout.wav', volume: .6);
  }

  static void harvest() {
    FlameAudio.play('harvest.wav', volume: .6);
  }

  static void inpross() {
    FlameAudio.play('inpross.wav', volume: .6);
  }

  static void congratulations() async {
    FlameAudio.bgm.pause();
    final overlay = AppService.navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.black54,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(22),
            child: Center(child: Icon(MyIcon.access, size: 50)),
          ),
        );
      },
    );
    overlay.insert(entry);
    await FlameAudio.play('congratulations.wav');
    await Future.delayed(const Duration(seconds: 2));
    entry.remove();
    FlameAudio.bgm.resume();
  }

  static void failure() async {
    FlameAudio.bgm.pause();
    await FlameAudio.play('failure.wav');
    FlameAudio.bgm.resume();
  }
}
