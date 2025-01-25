// lib/widgets/nbi_header.dart
import 'package:flutter/material.dart';

class NbiHeader extends StatelessWidget {
  final bool showBackButton;

  const NbiHeader({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.brown[900],
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          Image.asset(
            'assets/nbimain_logo.png',
            height: 60,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'REPUBLIC OF THE PHILIPPINES\nDEPARTMENT OF JUSTICE\nNATIONAL BUREAU OF INVESTIGATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Image.asset(
            'assets/bagong-pinas.png',
            height: 60,
          ),
        ],
      ),
    );
  }
}