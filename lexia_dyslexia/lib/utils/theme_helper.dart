import 'package:flutter/material.dart';

class ThemeHelper {
  // Feature card colors
  static Map<String, ColorPair> getFeatureCardColors() {
    return {
      'forum': ColorPair(
        baseColor: Colors.blue.shade100, 
        hoverColor: Colors.blue.shade200,
        iconColor: Colors.blue.shade700,
      ),
      'parent': ColorPair(
        baseColor: Colors.green.shade100, 
        hoverColor: Colors.green.shade200,
        iconColor: Colors.green.shade700,
      ),
      'teacher': ColorPair(
        baseColor: Colors.purple.shade100, 
        hoverColor: Colors.purple.shade200,
        iconColor: Colors.purple.shade700,
      ),
      'games': ColorPair(
        baseColor: Colors.amber.shade100, 
        hoverColor: Colors.amber.shade200,
        iconColor: Colors.amber.shade700,
      ),
      'resources': ColorPair(
        baseColor: Colors.teal.shade100, 
        hoverColor: Colors.teal.shade200,
        iconColor: Colors.teal.shade700,
      ),
    };
  }
  
  // Get specific feature color
  static ColorPair getColorForFeature(String feature) {
    final colors = getFeatureCardColors();
    return colors[feature] ?? 
      ColorPair(
        baseColor: Colors.grey.shade100, 
        hoverColor: Colors.grey.shade200,
        iconColor: Colors.grey.shade700,
      );
  }
  
  // Role-based colors
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return Colors.green;
      case 'teacher':
        return Colors.purple;
      case 'child':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class ColorPair {
  final Color baseColor;
  final Color hoverColor;
  final Color iconColor;
  
  ColorPair({
    required this.baseColor, 
    required this.hoverColor,
    required this.iconColor,
  });
}
