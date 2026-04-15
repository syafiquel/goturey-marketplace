import 'package:flutter/material.dart';

IconData iconFromName(String iconName) {
  switch (iconName) {
    case 'local_parking':
      return Icons.local_parking;
    case 'directions_boat':
      return Icons.directions_boat;
    case 'houseboat':
      return Icons.houseboat;
    case 'holiday_village':
      return Icons.holiday_village;
    case 'directions_walk':
      return Icons.directions_walk;
    case 'local_activity':
      return Icons.local_activity;
    case 'car_rental':
      return Icons.car_rental;
    case 'surfing':
      return Icons.surfing;
    case 'scuba_diving':
      return Icons.scuba_diving;
    case 'pool':
      return Icons.pool;
    default:
      return Icons.category;
  }
}

