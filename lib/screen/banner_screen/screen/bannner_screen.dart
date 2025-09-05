import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class BannnerScreen extends StatelessWidget {
  const BannnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Banner', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D0F2B),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              onPressed: () {},
              style: FilledButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}