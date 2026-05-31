// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:pagame06/providers/service.dart';

class Toast {
  static void success(String title) => _emit(title, Colors.green.shade700);

  static void error(String title) {
    _emit(title, Colors.red.shade700);
  }

  static void _emit(
    String title,
    Color color, {
    Duration duration = const Duration(seconds: 3), // Giảm xuống 3s cho đỡ lâu
  }) {
    show(title: title, primaryColor: color, duration: duration);
  }

  static final List<_ToastController> _stack = [];

  static void show({
    required String title,
    required Color primaryColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = AppService.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late final OverlayEntry entry;
    late final _ToastController controller;

    controller = _ToastController(
      title: title,
      color: primaryColor,
      onClose: () {
        _stack.remove(controller);
        entry.remove();
        _reindex();
      },
    );

    entry = OverlayEntry(builder: (_) => controller.build());
    controller.entry = entry;

    _stack.add(controller);
    overlay.insert(entry);
    _reindex();

    Future.delayed(duration, () {
      if (_stack.contains(controller)) {
        controller.onClose();
      }
    });
  }

  static void _reindex() {
    for (int i = 0; i < _stack.length; i++) {
      _stack[i].index.value = i;
    }
  }
}

class _ToastController {
  final String title;
  final Color color;
  final VoidCallback onClose;

  late OverlayEntry entry;
  final ValueNotifier<int> index = ValueNotifier(0);

  _ToastController({
    required this.title,
    required this.color,
    required this.onClose,
  });

  Widget build() {
    return _ToastWidget(
      title: title,
      primaryColor: color,
      index: index,
      onClose: onClose,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final VoidCallback onClose;
  final ValueNotifier<int> index;

  const _ToastWidget({
    required this.title,
    required this.primaryColor,
    required this.onClose,
    required this.index,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Hiệu ứng đi từ dưới nhích nhẹ lên một chút khi xuất hiện
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Thêm hiệu ứng mờ đậm dần cho đẹp và tự nhiên
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.index,
      builder: (_, i, _) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              // Bọc Material để tránh lỗi chữ gạch chân màu vàng trên Overlay
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Chữ viền trắng phía sau
                    Text(
                      '${widget.title} xu',
                      style:
                          const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ).copyWith(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 5
                              ..color = Colors.white,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 2. Chữ màu chính phía trước
                    Text(
                      '${widget.title} xu',
                      style: TextStyle(
                        fontSize: 50,
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
