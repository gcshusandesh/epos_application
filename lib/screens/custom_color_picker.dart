import 'package:flutter/material.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.availableColors = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.cyan,
    ],
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late Color _pickerColor;

  @override
  void initState() {
    super.initState();
    _pickerColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: widget.availableColors.length,
      itemBuilder: (context, index) {
        final color = widget.availableColors[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _pickerColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    color == _pickerColor ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
