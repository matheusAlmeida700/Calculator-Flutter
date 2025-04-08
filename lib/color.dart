import 'package:flutter/material.dart';

const orangeColor = Color(0xffD9802E);

final availableThemes = [
  const Color.fromARGB(255, 31, 31, 31),
  Colors.blue,
  Colors.green,
  Colors.pink,
];

final Map<int, Map<String, Color>> themeStyles = {
  Color.fromARGB(255, 31, 31, 31).value: {
    "operator": Color.fromARGB(141, 59, 59, 59),
    "button": Color.fromARGB(255, 73, 73, 73),
  },
  Colors.blue.value: {
    "operator": const Color.fromARGB(255, 30, 41, 101),
    "button": const Color.fromARGB(255, 36, 88, 180),
  },
  Colors.green.value: {
    "operator": const Color.fromARGB(255, 58, 83, 28),
    "button": const Color.fromARGB(255, 19, 137, 11),
  },
  Colors.pink.value: {
    "operator": const Color.fromARGB(255, 140, 11, 88),
    "button": const Color.fromARGB(255, 162, 38, 125),
  },
};
