class Planta {
  final int id;
  final String nombre;
  final double precio;
  final int existencias;

  const Planta({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.existencias,
  });

  factory Planta.desdeJson(Map<String, dynamic> json) => Planta(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        precio: (json['precio'] as num).toDouble(),
        existencias: json['existencias'] as int,
      );

  bool get disponible => existencias > 0;
}
