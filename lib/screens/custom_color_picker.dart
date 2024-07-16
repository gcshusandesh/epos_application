import 'package:flutter/material.dart';

class CustomBlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;

  const CustomBlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.availableColors = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.grey,
      Colors.pink,
      Colors.cyan,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: availableColors.length,
      itemBuilder: (context, index) {
        final color = availableColors[index];
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color == pickerColor ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
