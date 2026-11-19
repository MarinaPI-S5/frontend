import 'package:flutter/material.dart';

class SlideButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onSubmit;

  const SlideButton({
    super.key,
    required this.text,
    required this.onSubmit,
    this.color = Colors.green,
    this.backgroundColor = const Color(0xFFE8F2EC),
    this.icon = Icons.chevron_right,
  });

  @override
  State<SlideButton> createState() => _SlideButtonState();
}

class _SlideButtonState extends State<SlideButton> {
  double _position = 0;

  final double _thumbSize = 54;
  final double _padding = 4;

  void _onDragUpdate(DragUpdateDetails details, double maxPosition) {
    setState(() {
      _position = (_position + details.delta.dx).clamp(0.0, maxPosition);
    });
  }

  void _onDragEnd(double maxPosition) {
    if (_position >= maxPosition * 0.8) {
      widget.onSubmit();
    } else {
      setState(() {
        _position = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxPosition =
              constraints.maxWidth - _thumbSize - (_padding * 2);

          return Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: _padding + _position,
                  top: _padding,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) =>
                        _onDragUpdate(details, maxPosition),
                    onHorizontalDragEnd: (_) => _onDragEnd(maxPosition),
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
