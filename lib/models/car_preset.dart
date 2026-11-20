/// Representation of an RC car chassis setup preset.
///
/// Note: [igr] (Internal Gear Ratio) is strictly final/immutable once set.
class CarPreset {
  final String id;
  final String name;
  final double igr;
  final int defaultSpur;
  final int defaultPinion;
  final bool isBuiltIn;
  final bool isPinned;

  const CarPreset({
    required this.id,
    required this.name,
    required this.igr,
    required this.defaultSpur,
    required this.defaultPinion,
    this.isBuiltIn = false,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'igr': igr,
      'defaultSpur': defaultSpur,
      'defaultPinion': defaultPinion,
      'isBuiltIn': isBuiltIn,
      'isPinned': isPinned,
    };
  }

  factory CarPreset.fromJson(Map<String, dynamic> json) {
    return CarPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      igr: (json['igr'] as num).toDouble(),
      defaultSpur: (json['defaultSpur'] as num).toInt(),
      defaultPinion: (json['defaultPinion'] as num).toInt(),
      isBuiltIn: (json['isBuiltIn'] as bool?) ?? false,
      isPinned: (json['isPinned'] as bool?) ?? false,
    );
  }

  CarPreset copyWith({
    String? name,
    int? defaultSpur,
    int? defaultPinion,
    bool? isPinned,
  }) {
    // Note: igr and isBuiltIn are deliberately NOT alterable here to preserve kit integrity
    return CarPreset(
      id: id,
      name: name ?? this.name,
      igr: igr,
      defaultSpur: defaultSpur ?? this.defaultSpur,
      defaultPinion: defaultPinion ?? this.defaultPinion,
      isBuiltIn: isBuiltIn,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
