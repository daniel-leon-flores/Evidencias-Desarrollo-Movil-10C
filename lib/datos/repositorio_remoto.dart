import 'dart:convert';

import 'package:http/http.dart' as http;

import 'repositorio.dart';

typedef DesdeJson<T> = T Function(Map<String, dynamic> json);

/// Repositorio que lee una colección de la API del vivero.
///
/// Concentra en un solo lugar la petición, la validación del estado, la
/// decodificación y el mapeo. Cada recurso solo aporta su ruta y su
/// constructor desde JSON.
class RepositorioRemoto<T> implements Repositorio<T> {
  final String base;
  final String recurso;
  final DesdeJson<T> desdeJson;

  const RepositorioRemoto(this.base, this.recurso, this.desdeJson);

  @override
  Future<List<T>> obtenerTodos() async {
    final r = await http.get(Uri.parse('$base/$recurso'));
    if (r.statusCode != 200) { throw Exception('Error de red'); }
    final lista = jsonDecode(r.body) as List;
    return lista.map((e) => desdeJson(e)).toList();
  }
}
