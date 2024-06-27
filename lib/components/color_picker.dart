import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerExample extends StatelessWidget {
  const ColorPickerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/300?img=30'),
                          radius: 60,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Herman Yun'),
                            Divider(),
                            Text('foobar@example.com')
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Select a color',
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    BlockPicker(
                      pickerColor: Colors.red,
                      onColorChanged: (Color color) {},
                      layoutBuilder: (context, colors, child) {
                        return GridView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 100,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 100,
                            mainAxisSpacing: 10,
                          ),
                          children: [for (Color color in colors) child(color)],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: ElevatedButton(
              onPressed: () {},
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text('Save')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
