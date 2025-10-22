/// Extension methods for List operations used in tests and core functionality
extension ListExtensions<T> on List<T> {
  /// Safely get element at index, returns null if out of bounds
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get unique elements from list
  List<T> unique() {
    final seen = <T>{};
    final unique = <T>[];
    for (final item in this) {
      if (seen.add(item)) {
        unique.add(item);
      }
    }
    return unique;
  }
}

/// Extension methods for List<num> operations
extension NumListExtensions<T extends num> on List<T> {
  /// Safely calculate average, returns 0.0 if empty
  double safeAverage() {
    if (isEmpty) return 0.0;
    return fold<num>(0, (sum, item) => sum + item).toDouble() / length;
  }

  /// Safely get maximum value, returns 0 if empty
  T safeMax() {
    if (isEmpty) return 0 as T;
    return reduce((a, b) => a > b ? a : b);
  }

  /// Safely get minimum value, returns 0 if empty
  T safeMin() {
    if (isEmpty) return 0 as T;
    return reduce((a, b) => a < b ? a : b);
  }
}

/// Extension methods for List<String> operations
extension StringListExtensions on List<String> {
  /// Get most frequent element, returns null if empty
  String? mostFrequent() {
    if (isEmpty) return null;
    
    final counts = <String, int>{};
    for (final item in this) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    
    String? mostFrequent;
    int maxCount = 0;
    
    counts.forEach((item, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = item;
      }
    });
    
    return mostFrequent;
  }
}
