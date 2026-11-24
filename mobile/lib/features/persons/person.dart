/// Someone the customer insures (themselves or a family member), used for travel insurance.
class Person {
  const Person({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.relationshipLabel,
    required this.birthDate,
    required this.age,
    this.passportNo,
    this.nationalId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    final relationship = json['relationship'] as Map<String, dynamic>;
    return Person(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
      relationship: Relationship.fromValue(relationship['value'] as String),
      relationshipLabel: relationship['label'] as String,
      birthDate: json['birth_date'] as String,
      age: (json['age'] as num).toInt(),
      passportNo: json['passport_no'] as String?,
      nationalId: json['national_id'] as String?,
    );
  }

  final int id;
  final String fullName;
  final Relationship relationship;

  /// Localized by the server.
  final String relationshipLabel;
  final String birthDate;
  final int age;
  final String? passportNo;
  final String? nationalId;

  /// Travel insurance requires a passport for every traveller.
  bool get canTravel => passportNo != null && passportNo!.isNotEmpty;
}

enum Relationship {
  self('self'),
  spouse('spouse'),
  child('child'),
  parent('parent'),
  sibling('sibling'),
  other('other');

  const Relationship(this.value);

  final String value;

  static Relationship fromValue(String value) =>
      Relationship.values.firstWhere((r) => r.value == value, orElse: () => Relationship.other);
}

class PersonInput {
  const PersonInput({
    required this.fullName,
    required this.relationship,
    required this.birthDate,
    this.passportNo,
    this.nationalId,
  });

  final String fullName;
  final Relationship relationship;

  /// yyyy-MM-dd
  final String birthDate;
  final String? passportNo;
  final String? nationalId;

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'relationship': relationship.value,
    'birth_date': birthDate,
    'passport_no': passportNo,
    'national_id': nationalId,
  };
}
