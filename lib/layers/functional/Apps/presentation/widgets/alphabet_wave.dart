import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../technical/Theme/ripple_colors.dart';

class AlphabetWave extends StatefulWidget {
  const AlphabetWave({
    required this.letters,
    required this.onLetterSelected,
    super.key,
    this.maxShift = 56,
    this.spread = 2.2,
  });

  final List<String> letters;
  final ValueChanged<String> onLetterSelected;
  final double maxShift;
  final double spread;

  @override
  State<AlphabetWave> createState() => _AlphabetWaveState();
}

class _AlphabetWaveState extends State<AlphabetWave> with SingleTickerProviderStateMixin {
  late final AnimationController _intensity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 420),
  );
  double _focusY = 0;
  int? _selectedIndex;

  @override
  void dispose() {
    _intensity.dispose();
    super.dispose();
  }

  void _track(Offset localPosition, double height) {
    if (widget.letters.isEmpty) {
      return;
    }
    final double slot = height / widget.letters.length;
    final int index = (localPosition.dy / slot).floor().clamp(0, widget.letters.length - 1);
    setState(() => _focusY = localPosition.dy.clamp(0, height));
    if (index != _selectedIndex) {
      _selectedIndex = index;
      HapticFeedback.selectionClick();
      widget.onLetterSelected(widget.letters[index]);
    }
  }

  void _start(Offset localPosition, double height) {
    _intensity.forward();
    _track(localPosition, height);
  }

  void _release() {
    _intensity.reverse();
    _selectedIndex = null;
  }

  double _waveFactor(int index, double slot) {
    final double letterCenter = (index + 0.5) * slot;
    final double distance = (letterCenter - _focusY) / slot;
    return math.exp(-(distance * distance) / (2 * widget.spread * widget.spread)) * _intensity.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight;
        final double slot = widget.letters.isEmpty ? 0 : height / widget.letters.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (DragStartDetails details) => _start(details.localPosition, height),
          onVerticalDragUpdate: (DragUpdateDetails details) => _track(details.localPosition, height),
          onVerticalDragEnd: (_) => _release(),
          onVerticalDragCancel: _release,
          onTapDown: (TapDownDetails details) => _start(details.localPosition, height),
          onTapUp: (_) => _release(),
          child: AnimatedBuilder(
            animation: _intensity,
            builder: (BuildContext context, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (int index = 0; index < widget.letters.length; index++)
                    _WaveLetter(
                      letter: widget.letters[index],
                      height: slot,
                      factor: _waveFactor(index, slot),
                      maxShift: widget.maxShift,
                      isSelected: index == _selectedIndex,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _WaveLetter extends StatelessWidget {
  const _WaveLetter({
    required this.letter,
    required this.height,
    required this.factor,
    required this.maxShift,
    required this.isSelected,
  });

  final String letter;
  final double height;
  final double factor;
  final double maxShift;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? RippleColors.accent
        : Color.lerp(RippleColors.textMuted, RippleColors.textPrimary, factor) ?? RippleColors.textMuted;
    return SizedBox(
      height: height,
      width: 28,
      child: Transform.translate(
        offset: Offset(-maxShift * factor, 0),
        child: Transform.scale(
          scale: 1 + factor * (isSelected ? 1.4 : 0.6),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
