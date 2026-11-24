import '../persons/person.dart';

class TravelDuration {
  const TravelDuration({required this.days, required this.pricePerTraveller});

  factory TravelDuration.fromJson(Map<String, dynamic> json) => TravelDuration(
    days: (json['days'] as num).toInt(),
    pricePerTraveller: double.parse(json['price_per_traveller'].toString()),
  );

  final int days;
  final double pricePerTraveller;
}

class TravelZone {
  const TravelZone({required this.value, required this.label, required this.description, required this.durations});

  factory TravelZone.fromJson(Map<String, dynamic> json) => TravelZone(
    value: json['value'] as String,
    label: json['label'] as String,
    description: json['description'] as String,
    durations: (json['durations'] as List).cast<Map<String, dynamic>>().map(TravelDuration.fromJson).toList(),
  );

  final String value;
  final String label;
  final String description;
  final List<TravelDuration> durations;

  TravelDuration? duration(int days) => durations.where((d) => d.days == days).firstOrNull;

  /// Cheapest trip, shown as "from …".
  double get startingPrice => durations.map((d) => d.pricePerTraveller).reduce((a, b) => a < b ? a : b);
}

class TravelOptions {
  const TravelOptions({required this.zones, required this.maxTravellers, required this.maxStartDaysAhead});

  factory TravelOptions.fromJson(Map<String, dynamic> json) => TravelOptions(
    zones: (json['zones'] as List).cast<Map<String, dynamic>>().map(TravelZone.fromJson).toList(),
    maxTravellers: (json['max_travellers'] as num).toInt(),
    maxStartDaysAhead: (json['max_start_days_ahead'] as num).toInt(),
  );

  final List<TravelZone> zones;
  final int maxTravellers;
  final int maxStartDaysAhead;

  TravelZone? zone(String value) => zones.where((z) => z.value == value).firstOrNull;
}

/// Everything chosen on the first step, passed to the review step.
class TravelSelection {
  const TravelSelection({
    required this.zone,
    required this.duration,
    required this.startDate,
    required this.travellers,
  });

  final TravelZone zone;
  final TravelDuration duration;
  final DateTime startDate;
  final List<Person> travellers;

  DateTime get endDate => startDate.add(Duration(days: duration.days - 1));

  double get total => duration.pricePerTraveller * travellers.length;
}

/// Same money format the API uses ("170.00").
String amount(double value) => value.toStringAsFixed(2);
