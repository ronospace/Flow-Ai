
import 'package:flutter/material.dart';

/// Optimized image caching configuration for better performance
class ImageCacheConfig {
  static void configure() {
    // Increase image cache size for better performance
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 200 * 1024 * 1024; // 200MB
  }
}
