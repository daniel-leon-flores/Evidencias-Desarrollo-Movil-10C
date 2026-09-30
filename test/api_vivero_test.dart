import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:vivero_xochicalco/vivero_xochicalco.dart';

const base = 'https://api.vivero-xochicalco.test';

final plantasJson = [
  {'id': 1, 'nombre': 'Buganvilia', 'precio': 120, 'existencias': 8},
  {'id': 2, 'nombre': 'Lavanda', 'precio': 85.5, 'existencias': 0},
];

final pedidosJson = [
  {'id': 10, 'cliente': 'Mostrador', 'estado': 'pendiente', 'total': 205.5},
  {'id': 11, 'cliente': 'Rosa Pérez', 'estado': 'confirmado', 'total': 340},
];

/// Simula la API del vivero y registra las URL solicitadas.
MockClient apiSimulada(List<Uri> solicitadas, {int status = 200}) =>
    MockClient((req) async {
      solicitadas.add(req.url);
      final cuerpo = switch (req.url.path) {
        '/plantas' => plantasJson,
        '/pedidos' => pedidosJson,
        _ => <Object>[],
      };
      return http.Response(jsonEncode(cuerpo), status);
    });

void main() {
  const api = ApiVivero(base);

  group('obtenerPlantas', () {
    test('consulta $base/plantas y convierte cada elemento en Planta', () async {
      final solicitadas = <Uri>[];
      final plantas = await http.runWithClient(
        api.obtenerPlantas,
        () => apiSimulada(solicitadas),
      );

      expect(solicitadas, [Uri.parse('$base/plantas')]);
      expect(plantas, hasLength(2));
      expect(plantas.first.nombre, 'Buganvilia');
      expect(plantas.first.precio, 120.0);
      expect(plantas.first.disponible, isTrue);
      expect(plantas.last.disponible, isFalse);
    });

    test('lanza Exception("Error de red") si el estado no es 200', () async {
      await expectLater(
        http.runWithClient(
          api.obtenerPlantas,
          () => apiSimulada([], status: 500),
        ),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'mensaje', 'Exception: Error de red')),
      );
    });
  });

  group('obtenerPedidos', () {
    test('consulta $base/pedidos y convierte cada elemento en Pedido', () async {
      final solicitadas = <Uri>[];
      final pedidos = await http.runWithClient(
        api.obtenerPedidos,
        () => apiSimulada(solicitadas),
      );

      expect(solicitadas, [Uri.parse('$base/pedidos')]);
      expect(pedidos, hasLength(2));
      expect(pedidos.first.estado, 'pendiente');
      expect(pedidos.last.cliente, 'Rosa Pérez');
      expect(pedidos.last.total, 340.0);
    });

    test('lanza Exception("Error de red") si el estado no es 200', () async {
      await expectLater(
        http.runWithClient(
          api.obtenerPedidos,
          () => apiSimulada([], status: 404),
        ),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'mensaje', 'Exception: Error de red')),
      );
    });
  });
}
