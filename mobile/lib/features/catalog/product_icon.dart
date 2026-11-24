import 'package:flutter/material.dart';

/// Maps the catalog's icon keys (config/products.php) to app icons.
IconData productIcon(String key) => switch (key) {
  'car' => Icons.directions_car_outlined,
  'luggage' => Icons.luggage_outlined,
  'card' => Icons.badge_outlined,
  'worker' => Icons.engineering_outlined,
  'stethoscope' => Icons.medical_services_outlined,
  'ship' => Icons.directions_boat_outlined,
  _ => Icons.shield_outlined,
};
