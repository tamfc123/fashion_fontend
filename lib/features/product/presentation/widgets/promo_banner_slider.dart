import 'package:flutter/material.dart';

class PromoBannerSlider extends StatelessWidget {
  const PromoBannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Graphic / Pattern placeholder
          Positioned(
            right: -50,
            bottom: -50,
            child: Icon(
              Icons.star,
              size: 200,
              color: Colors.white.withAlpha(20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BỘ SƯU TẬP MỚI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Khám phá bộ sưu tập mới',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
