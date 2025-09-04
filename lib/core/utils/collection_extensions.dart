/// 📚 Collection Extensions
/// Utility extensions for collection operations
extension ListExtensions<T> on List<T> {
  /// Takes the last n elements from the list
  List<T> takeLast(int count) {
    if (count >= length) return this;
    if (count <= 0) return [];
    return sublist(length - count);
  }

  /// Takes the last n elements as an iterable
  Iterable<T> takeLastIterable(int count) {
    return takeLast(count);
  }

  /// Gets a safe element at index, returns null if out of bounds
  T? safeElementAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Chunks the list into smaller lists of the specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Chunk size must be positive');
    
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  /// Groups elements by a key function
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => <T>[]).add(element);
    }
    return map;
  }
}

extension IterableExtensions<T> on Iterable<T> {
  /// Finds the index of the first element that satisfies the predicate
  int indexWhereOrNull(bool Function(T) test) {
    int index = 0;
    for (final element in this) {
      if (test(element)) return index;
      index++;
    }
    return -1;
  }

  /// Gets the first element that satisfies the predicate, or null if none found
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Gets the last element that satisfies the predicate, or null if none found
  T? lastWhereOrNull(bool Function(T) test) {
    T? result;
    for (final element in this) {
      if (test(element)) result = element;
    }
    return result;
  }

  /// Converts to a list if not already a list
  List<T> toListIfNeeded() {
    if (this is List<T>) return this as List<T>;
    return toList();
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Gets a value by key, returning a default value if key doesn't exist
  V getOrElse(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Adds all entries from another map, with an optional value transformer
  void addAllTransformed<V2>(Map<K, V2> other, V Function(V2) transform) {
    other.forEach((key, value) {
      this[key] = transform(value);
    });
  }
}
