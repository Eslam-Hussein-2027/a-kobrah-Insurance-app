class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNo,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.engineCc,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: (json['id'] as num).toInt(),
    plateNo: json['plate_no'] as String,
    vin: json['vin'] as String,
    make: json['make'] as String,
    model: json['model'] as String,
    year: (json['year'] as num).toInt(),
    engineCc: (json['engine_cc'] as num).toInt(),
  );

  final int id;
  final String plateNo;
  final String vin;
  final String make;
  final String model;
  final int year;
  final int engineCc;

  String get title => '$make $model';
}

class VehicleInput {
  const VehicleInput({
    required this.plateNo,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.engineCc,
  });

  final String plateNo;
  final String vin;
  final String make;
  final String model;
  final int year;
  final int engineCc;

  Map<String, dynamic> toJson() => {
    'plate_no': plateNo,
    'vin': vin,
    'make': make,
    'model': model,
    'year': year,
    'engine_cc': engineCc,
  };
}
