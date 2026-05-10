import 'package:equatable/equatable.dart';

enum HomeChurchCategory { geographical, ministry, special }

extension HomeChurchCategoryX on HomeChurchCategory {
  String get displayName {
    switch (this) {
      case HomeChurchCategory.geographical: return 'Geographical';
      case HomeChurchCategory.ministry:     return 'Ministry / Youth';
      case HomeChurchCategory.special:      return 'Special';
    }
  }
  static HomeChurchCategory fromString(String v) {
    switch (v.toLowerCase()) {
      case 'ministry': return HomeChurchCategory.ministry;
      case 'special':  return HomeChurchCategory.special;
      default:         return HomeChurchCategory.geographical;
    }
  }
}

class HomeChurch extends Equatable {
  final int? id;
  final int churchId;
  final String name;
  final HomeChurchCategory category;
  final int expectedMembership;
  final int expectedAtKcc;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HomeChurch({
    this.id,
    required this.churchId,
    required this.name,
    this.category = HomeChurchCategory.geographical,
    this.expectedMembership = 0,
    this.expectedAtKcc = 0,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  HomeChurch copyWith({
    int? id, int? churchId, String? name, HomeChurchCategory? category,
    int? expectedMembership, int? expectedAtKcc, bool? isActive,
    int? sortOrder, DateTime? createdAt, DateTime? updatedAt,
  }) => HomeChurch(
    id: id ?? this.id, churchId: churchId ?? this.churchId,
    name: name ?? this.name, category: category ?? this.category,
    expectedMembership: expectedMembership ?? this.expectedMembership,
    expectedAtKcc: expectedAtKcc ?? this.expectedAtKcc,
    isActive: isActive ?? this.isActive, sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'churchId': churchId, 'name': name,
    'category': category.name,
    'expectedMembership': expectedMembership, 'expectedAtKcc': expectedAtKcc,
    'isActive': isActive, 'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory HomeChurch.fromJson(Map<String, dynamic> j) => HomeChurch(
    id: j['id'] as int?,
    churchId: j['churchId'] as int,
    name: j['name'] as String,
    category: HomeChurchCategoryX.fromString(j['category'] as String? ?? ''),
    expectedMembership: j['expectedMembership'] as int? ?? 0,
    expectedAtKcc: j['expectedAtKcc'] as int? ?? 0,
    isActive: j['isActive'] as bool? ?? true,
    sortOrder: j['sortOrder'] as int? ?? 0,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  String? validate() {
    if (name.trim().isEmpty) return 'Home church name cannot be empty';
    if (name.length > 200) return 'Name cannot exceed 200 characters';
    if (expectedMembership < 0) return 'Expected membership cannot be negative';
    if (expectedAtKcc < 0) return 'Expected at KCC cannot be negative';
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [id, churchId, name, category, expectedMembership,
    expectedAtKcc, isActive, sortOrder, createdAt, updatedAt];
}
