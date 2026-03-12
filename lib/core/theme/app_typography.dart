import 'package:flutter/material.dart';

abstract final class AppTypography {
  // Scale: 10, 12, 14, 16, 20, 32
  // Line heights: multiples of 4

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    height: 1.6,
  ); // 16dp line height
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.33,
  ); // 16dp
  static const TextStyle body = TextStyle(fontSize: 14, height: 1.43); // 20dp
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
  ); // 24dp
  static const TextStyle title = TextStyle(fontSize: 20, height: 1.4); // 28dp
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.25,
  ); // 40dp
}
