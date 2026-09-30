import '../modelos/pedido.dart';
import '../modelos/planta.dart';
import 'repositorio.dart';
import 'repositorio_remoto.dart';

/// Acceso a la API propia del Vivero Xochicalco.
class ApiVivero {
  final String base;

  const ApiVivero(this.base);

  Repositorio<Planta> get plantas =>
      RepositorioRemoto(base, 'plantas', Planta.desdeJson);

  Repositorio<Pedido> get pedidos =>
      RepositorioRemoto(base, 'pedidos', Pedido.desdeJson);

  Future<List<Planta>> obtenerPlantas() => plantas.obtenerTodos();

  Future<List<Pedido>> obtenerPedidos() => pedidos.obtenerTodos();
}
