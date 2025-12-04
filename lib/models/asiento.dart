class Asiento {
  final int numero;
  final bool disponible;
  final String? pasajero;

  Asiento({
    required this.numero,
    this.disponible = true,
    this.pasajero,
  });

  Asiento copyWith({
    int? numero,
    bool? disponible,
    String? pasajero,
  }) {
    return Asiento(
      numero: numero ?? this.numero,
      disponible: disponible ?? this.disponible,
      pasajero: pasajero ?? this.pasajero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'disponible': disponible,
      'pasajero': pasajero,
    };
  }

  factory Asiento.fromJson(Map<String, dynamic> json) {
    return Asiento(
      numero: json['numero'],
      disponible: json['disponible'],
      pasajero: json['pasajero'],
    );
  }
}
