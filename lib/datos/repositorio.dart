/// Contrato de acceso a una colección de datos del vivero.
///
/// Las pantallas dependen de esta interfaz y no saben si los datos vienen
/// de la API del vivero o de una fuente local.
abstract interface class Repositorio<T> {
  Future<List<T>> obtenerTodos();
}
