import 'package:equatable/equatable.dart';

/// Represents a church entity in the system
class Church extends Equatable {
  final int? id;
  final String name;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Church({
    this.id,
    required this.name,
    this.address,
    this.contactEmail,
    this.contactPhone,
    this.currency = 'USD',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this Church with updated fields
  Church copyWith({
    int? id,
    String? name,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Church(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this Church to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a Church from a JSON map
  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      id: json['id'] as int?,
      name: json['name'] as String,
      address: json['address'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Validates the church model
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Church name cannot be empty';
    }
    if (name.length > 200) {
      return 'Church name cannot exceed 200 characters';
    }
    if (contactEmail != null && contactEmail!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(contactEmail!)) {
        return 'Invalid email format';
      }
    }
    return null;
  }

  /// Checks if this church model is valid
  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    contactEmail,
    contactPhone,
    currency,
    createdAt,
    updatedAt,
  ];
}
