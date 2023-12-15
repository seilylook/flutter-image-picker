import 'package:flutter/material.dart';

class EmoticonPicker extends StatefulWidget {
  final VoidCallback onTransform;
  final String imgPath;
  final bool isSelected;
  const EmoticonPicker({
    super.key,
    required this.imgPath,
    required this.onTransform,
    required this.isSelected,
  });

  @override
  State<EmoticonPicker> createState() => _EmoticonPickerState();
}

class _EmoticonPickerState extends State<EmoticonPicker> {
  double scale = 1;
  double hTransform = 0;
  double vTransform = 0;
  double actualScale = 1;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(hTransform, vTransform)
        ..scale(scale, scale),
      child: Container(
          decoration: widget.isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                )
              : BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
          child: GestureDetector(
            onTap: () {
              widget.onTransform();
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                scale = details.scale * actualScale;
                vTransform += details.focalPointDelta.dy;
                hTransform += details.focalPointDelta.dx;
              });
            },
            onScaleEnd: (ScaleEndDetails details) {
              actualScale = scale;
            },
            child: Image.asset(widget.imgPath),
          )),
    );
  }
}
