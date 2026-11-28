/// A code with its label in the app language, e.g. (value: 'white', label: 'أبيض').
typedef Choice = ({String value, String label});

Choice? _choice(Object? json) =>
    json is Map<String, dynamic> ? (value: json['value'] as String, label: json['label'] as String) : null;

List<Choice> _choices(Object? json) => [for (final item in (json as List? ?? const [])) ?_choice(item)];

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNo,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.engineCc,
    this.ownerName,
    this.ownerAddress,
    this.color,
    this.countryOfOrigin,
    this.licensePurpose,
    this.seats,
    this.licensingAuthority,
    this.detailsComplete = false,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: (json['id'] as num).toInt(),
    plateNo: json['plate_no'] as String,
    vin: json['vin'] as String,
    make: json['make'] as String,
    model: json['model'] as String,
    year: (json['year'] as num).toInt(),
    engineCc: (json['engine_cc'] as num).toInt(),
    ownerName: json['owner_name'] as String?,
    ownerAddress: json['owner_address'] as String?,
    color: _choice(json['color']),
    countryOfOrigin: _choice(json['country_of_origin']),
    licensePurpose: _choice(json['license_purpose']),
    seats: (json['seats'] as num?)?.toInt(),
    licensingAuthority: _choice(json['licensing_authority']),
    detailsComplete: json['details_complete'] == true,
  );

  final int id;
  final String plateNo;
  final String vin;
  final String make;
  final String model;
  final int year;
  final int engineCc;

  // Registration details. Missing on vehicles added before they were asked;
  // the app asks to complete them before a new policy is issued.
  final String? ownerName;
  final String? ownerAddress;
  final Choice? color;
  final Choice? countryOfOrigin;
  final Choice? licensePurpose;
  final int? seats;
  final Choice? licensingAuthority;
  final bool detailsComplete;

  String get title => '$make $model';
}

class VehicleInput {
  const VehicleInput({
    required this.ownerName,
    required this.ownerAddress,
    required this.plateNo,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.engineCc,
    required this.color,
    required this.countryOfOrigin,
    required this.licensePurpose,
    required this.seats,
    required this.licensingAuthority,
  });

  final String ownerName;
  final String ownerAddress;
  final String plateNo;
  final String vin;
  final String make;
  final String model;
  final int year;
  final int engineCc;
  final String color;
  final String countryOfOrigin;
  final String licensePurpose;
  final int seats;
  final String licensingAuthority;

  Map<String, dynamic> toJson() => {
    'owner_name': ownerName,
    'owner_address': ownerAddress,
    'plate_no': plateNo,
    'vin': vin,
    'make': make,
    'model': model,
    'year': year,
    'engine_cc': engineCc,
    'color': color,
    'country_of_origin': countryOfOrigin,
    'license_purpose': licensePurpose,
    'seats': seats,
    'licensing_authority': licensingAuthority,
  };
}

/// Lists for the add / edit vehicle form (GET /vehicles/options).
class VehicleOptions {
  const VehicleOptions({
    required this.makes,
    required this.colors,
    required this.countries,
    required this.licensePurposes,
    required this.licensingAuthorities,
    required this.minYear,
    required this.maxYear,
    required this.minSeats,
    required this.maxSeats,
  });

  factory VehicleOptions.fromJson(Map<String, dynamic> json) {
    final years = json['years'] as Map<String, dynamic>;
    final seats = json['seats'] as Map<String, dynamic>;
    return VehicleOptions(
      makes: _choices(json['makes']),
      colors: _choices(json['colors']),
      countries: _choices(json['countries']),
      licensePurposes: _choices(json['license_purposes']),
      licensingAuthorities: _choices(json['licensing_authorities']),
      minYear: (years['min'] as num).toInt(),
      maxYear: (years['max'] as num).toInt(),
      minSeats: (seats['min'] as num).toInt(),
      maxSeats: (seats['max'] as num).toInt(),
    );
  }

  final List<Choice> makes;
  final List<Choice> colors;
  final List<Choice> countries;
  final List<Choice> licensePurposes;
  final List<Choice> licensingAuthorities;
  final int minYear;
  final int maxYear;
  final int minSeats;
  final int maxSeats;

  /// Newest first, as people usually own recent cars.
  List<Choice> get years => [for (var y = maxYear; y >= minYear; y--) (value: '$y', label: '$y')];
}
