import 'package:flutter/material.dart';

/// Reward model for gamification system
class Reward {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type; // points, discount, premium_feature, physical, virtual
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final int pointsCost;
  final double? discountValue;
  final String? discountCode;
  final bool isAvailable;
  final bool isLimited;
  final int? limitedQuantity;
  final int? remainingQuantity;
  final bool isPremium;
  final List<String> requirements;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.pointsCost,
    this.discountValue,
    this.discountCode,
    this.isAvailable = true,
    this.isLimited = false,
    this.limitedQuantity,
    this.remainingQuantity,
    this.isPremium = false,
    this.requirements = const [],
    this.expiresAt,
    required this.createdAt,
    this.metadata,
  });

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    IconData? icon,
    Color? primaryColor,
    Color? accentColor,
    int? pointsCost,
    double? discountValue,
    String? discountCode,
    bool? isAvailable,
    bool? isLimited,
    int? limitedQuantity,
    int? remainingQuantity,
    bool? isPremium,
    List<String>? requirements,
    DateTime? expiresAt,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      pointsCost: pointsCost ?? this.pointsCost,
      discountValue: discountValue ?? this.discountValue,
      discountCode: discountCode ?? this.discountCode,
      isAvailable: isAvailable ?? this.isAvailable,
      isLimited: isLimited ?? this.isLimited,
      limitedQuantity: limitedQuantity ?? this.limitedQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      isPremium: isPremium ?? this.isPremium,
      requirements: requirements ?? this.requirements,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isOutOfStock {
    if (!isLimited) return false;
    return remainingQuantity != null && remainingQuantity! <= 0;
  }

  bool get canRedeem => isAvailable && !isExpired && !isOutOfStock;

  String get availabilityStatus {
    if (isExpired) return 'Expired';
    if (isOutOfStock) return 'Out of Stock';
    if (!isAvailable) return 'Unavailable';
    return 'Available';
  }

  Color get availabilityColor {
    if (!canRedeem) return Colors.grey;
    if (isLimited && remainingQuantity != null && remainingQuantity! < 5) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'points':
        return 'Points Bonus';
      case 'discount':
        return 'Discount Code';
      case 'premium_feature':
        return 'Premium Feature';
      case 'physical':
        return 'Physical Item';
      case 'virtual':
        return 'Virtual Item';
      default:
        return 'Reward';
    }
  }

  String get valueDisplay {
    switch (type.toLowerCase()) {
      case 'discount':
        if (discountValue != null) {
          return '${(discountValue! * 100).toInt()}% OFF';
        }
        return 'Discount';
      case 'points':
        return '+$pointsCost Points';
      default:
        return '';
    }
  }

  String get stockDisplay {
    if (!isLimited) return '';
    if (limitedQuantity != null && remainingQuantity != null) {
      return '$remainingQuantity/$limitedQuantity left';
    }
    if (remainingQuantity != null) {
      return '$remainingQuantity left';
    }
    return 'Limited';
  }

  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return null;
    return expiresAt!.difference(now);
  }

  String get expiryText {
    final duration = timeUntilExpiry;
    if (duration == null) return '';
    
    if (duration.inDays > 0) {
      return 'Expires in ${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return 'Expires in ${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return 'Expires in ${duration.inMinutes} minutes';
    } else {
      return 'Expires soon';
    }
  }

  bool get isHighDemand {
    return isLimited && 
           remainingQuantity != null && 
           limitedQuantity != null &&
           (remainingQuantity! / limitedQuantity!) < 0.3;
  }

  String get urgencyText {
    if (isHighDemand) return 'High Demand!';
    if (isExpired) return 'Expired';
    if (isOutOfStock) return 'Sold Out';
    
    final duration = timeUntilExpiry;
    if (duration != null && duration.inHours < 24) {
      return 'Hurry Up!';
    }
    
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'icon': icon.codePoint,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'pointsCost': pointsCost,
      'discountValue': discountValue,
      'discountCode': discountCode,
      'isAvailable': isAvailable,
      'isLimited': isLimited,
      'limitedQuantity': limitedQuantity,
      'remainingQuantity': remainingQuantity,
      'isPremium': isPremium,
      'requirements': requirements,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      primaryColor: Color(json['primaryColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      pointsCost: json['pointsCost'] as int,
      discountValue: json['discountValue'] as double?,
      discountCode: json['discountCode'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isLimited: json['isLimited'] as bool? ?? false,
      limitedQuantity: json['limitedQuantity'] as int?,
      remainingQuantity: json['remainingQuantity'] as int?,
      isPremium: json['isPremium'] as bool? ?? false,
      requirements: List<String>.from(json['requirements'] as List? ?? []),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reward && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reward(id: $id, title: $title, pointsCost: $pointsCost)';
  }
}
