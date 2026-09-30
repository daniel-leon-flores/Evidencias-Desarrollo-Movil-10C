class Pedido {
  final int id;
  final String cliente;
  final String estado;
  final double total;

  const Pedido({
    required this.id,
    required this.cliente,
    required this.estado,
    required this.total,
  });

  factory Pedido.desdeJson(Map<String, dynamic> json) => Pedido(
        id: json['id'] as int,
        cliente: json['cliente'] as String,
        estado: json['estado'] as String,
        total: (json['total'] as num).toDouble(),
      );
}
