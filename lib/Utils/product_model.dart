class Product {
  final String name;
  final String code;
  final double mass;
  final double energy;
  final double protein;
  final double carbs;
  final double fat;
  final double sugars;
  final String ingredients;
  final String imageUrl;
  final double sodium;
  final double fiber;

  Product({
    required this.name,
    required dynamic code,
    required dynamic mass,
    required dynamic energy,
    required dynamic protein,
    required dynamic carbs,
    required dynamic fat,
    required dynamic sugars,
    required dynamic sodium,
    required dynamic fiber,
    required this.ingredients,
    required this.imageUrl,
  })  : code = code ?? 'missing barcode',
        mass = _toDouble(mass).roundToDouble(),
        energy = _processMacro(energy, mass, 0.239005736),
        protein = _processMacro(protein, mass),
        carbs = _processMacro(carbs, mass),
        fat = _processMacro(fat, mass),
        sugars = _processMacro(sugars, mass),
        sodium = _processMacro(sodium, mass),
        fiber = _processMacro(fiber, mass);
  static double _toDouble(dynamic value) =>
      value is String ? double.tryParse(value) ?? double.nan : value.toDouble();

  static double _normalize(double macro, double mass) =>
      macro.isNaN || mass.isNaN ? double.nan : macro * mass / 100;

  static double _processMacro(dynamic macro, dynamic mass,
      [double multiplier = 1.0]) {
    double macroValue = _toDouble(macro);
    double massValue = _toDouble(mass);
    if (massValue.isNaN || massValue == 0) {
      return macroValue.isNaN ? double.nan : macroValue.roundToDouble();
    } else {
      double normalizedValue = _normalize(macroValue, massValue) * multiplier;
      return normalizedValue.isNaN
          ? double.nan
          : normalizedValue.roundToDouble();
    }
  }

  double getProperty(String property) {
    switch (property) {
      case 'energy':
        return energy;
      case 'protein':
        return protein;
      case 'carbs':
        return carbs;
      case 'fat':
        return fat;
      case 'sugars':
        return sugars;
      case 'sodium':
        return sodium;
      case 'fiber':
        return fiber;
      default:
        throw ArgumentError('Invalid property name: $property');
    }
  }
}
