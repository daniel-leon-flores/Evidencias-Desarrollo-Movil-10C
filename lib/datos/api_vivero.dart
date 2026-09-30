import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/pedido.dart';
import '../modelos/planta.dart';

/// Acceso a la API propia del Vivero Xochicalco.
class ApiVivero {
  final String base;

  const ApiVivero(this.base);

  Future<List<Planta>> obtenerPlantas() async {
    final r = await http.get(Uri.parse('$base/plantas'));
    if (r.statusCode != 200) { throw Exception('Error de red'); }
    final lista = jsonDecode(r.body) as List;
    return lista.map((e) => Planta.desdeJson(e)).toList();
  }

  Future<List<Pedido>> obtenerPedidos() async {
    final r = await http.get(Uri.parse('$base/pedidos'));
    if (r.statusCode != 200) { throw Exception('Error de red'); }
    final lista = jsonDecode(r.body) as List;
    return lista.map((e) => Pedido.desdeJson(e)).toList();
  }
}
