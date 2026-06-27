import 'package:hive/hive.dart';

enum RiskProfile { conservative, moderate, aggressive }

class InvestorProfile {
  final String id;
  final String name;
  final String cpf;
  final DateTime birthDate;
  final String maritalStatus;
  final int dependents;
  final double monthlyIncome;
  final double totalPatrimony;
  final RiskProfile riskProfile;
  final int investmentHorizon;
  final List<String> objectives;
  final bool hasMinors;
  final bool hasForeignAssets;
  final double foreignAssetsValue;
  final String residenceCountry;
  final String taxResidency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestorProfile({
    required this.id,
    required this.name,
    required this.cpf,
    required this.birthDate,
    required this.maritalStatus,
    required this.dependents,
    required this.monthlyIncome,
    required this.totalPatrimony,
    required this.riskProfile,
    required this.investmentHorizon,
    required this.objectives,
    required this.hasMinors,
    required this.hasForeignAssets,
    required this.foreignAssetsValue,
    required this.residenceCountry,
    required this.taxResidency,
    required this.createdAt,
    required this.updatedAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get riskProfileName {
    switch (riskProfile) {
      case RiskProfile.conservative:
        return 'Conservador';
      case RiskProfile.moderate:
        return 'Moderado';
      case RiskProfile.aggressive:
        return 'Arrojado';
    }
  }

  InvestorProfile copyWith({
    String? id,
    String? name,
    String? cpf,
    DateTime? birthDate,
    String? maritalStatus,
    int? dependents,
    double? monthlyIncome,
    double? totalPatrimony,
    RiskProfile? riskProfile,
    int? investmentHorizon,
    List<String>? objectives,
    bool? hasMinors,
    bool? hasForeignAssets,
    double? foreignAssetsValue,
    String? residenceCountry,
    String? taxResidency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dependents: dependents ?? this.dependents,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      totalPatrimony: totalPatrimony ?? this.totalPatrimony,
      riskProfile: riskProfile ?? this.riskProfile,
      investmentHorizon: investmentHorizon ?? this.investmentHorizon,
      objectives: objectives ?? this.objectives,
      hasMinors: hasMinors ?? this.hasMinors,
      hasForeignAssets: hasForeignAssets ?? this.hasForeignAssets,
      foreignAssetsValue: foreignAssetsValue ?? this.foreignAssetsValue,
      residenceCountry: residenceCountry ?? this.residenceCountry,
      taxResidency: taxResidency ?? this.taxResidency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'birthDate': birthDate.toIso8601String(),
      'maritalStatus': maritalStatus,
      'dependents': dependents,
      'monthlyIncome': monthlyIncome,
      'totalPatrimony': totalPatrimony,
      'riskProfile': riskProfile.index,
      'investmentHorizon': investmentHorizon,
      'objectives': objectives,
      'hasMinors': hasMinors,
      'hasForeignAssets': hasForeignAssets,
      'foreignAssetsValue': foreignAssetsValue,
      'residenceCountry': residenceCountry,
      'taxResidency': taxResidency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InvestorProfile.fromMap(Map<dynamic, dynamic> map) {
    return InvestorProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      cpf: map['cpf'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      maritalStatus: map['maritalStatus'] as String,
      dependents: map['dependents'] as int,
      monthlyIncome: (map['monthlyIncome'] as num).toDouble(),
      totalPatrimony: (map['totalPatrimony'] as num).toDouble(),
      riskProfile: RiskProfile.values[map['riskProfile'] as int],
      investmentHorizon: map['investmentHorizon'] as int,
      objectives: List<String>.from(map['objectives'] as List),
      hasMinors: map['hasMinors'] as bool,
      hasForeignAssets: map['hasForeignAssets'] as bool,
      foreignAssetsValue: (map['foreignAssetsValue'] as num).toDouble(),
      residenceCountry: map['residenceCountry'] as String,
      taxResidency: map['taxResidency'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

class InvestorProfileAdapter extends TypeAdapter<Map<dynamic, dynamic>> {
  @override
  final int typeId = 0;

  @override
  Map<dynamic, dynamic> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <dynamic, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.read();
      final value = reader.read();
      fields[key] = value;
    }
    return fields;
  }

  @override
  void write(BinaryWriter writer, Map<dynamic, dynamic> obj) {
    writer.writeByte(obj.length);
    for (final entry in obj.entries) {
      writer.write(entry.key);
      writer.write(entry.value);
    }
  }
}
