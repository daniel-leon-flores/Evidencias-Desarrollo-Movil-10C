# Hallazgos: duplicación en la capa de datos del vivero

Práctica 1, Parte II · Rama `s02-patrones`

## 2.1 Fragmentos duplicados

**Archivo:** `lib/datos/api_vivero.dart`, clase `ApiVivero` (versión original, commit `09e593a`)

| # | Función | Líneas |
|---|---|---|
| 1 | `obtenerPlantas()` | 14–19 |
| 2 | `obtenerPedidos()` | 21–26 |

```dart
// Fragmento 1: obtenerPlantas(), líneas 14–19
Future<List<Planta>> obtenerPlantas() async {
  final r = await http.get(Uri.parse('$base/plantas'));
  if (r.statusCode != 200) { throw Exception('Error de red'); }
  final lista = jsonDecode(r.body) as List;
  return lista.map((e) => Planta.desdeJson(e)).toList();
}

// Fragmento 2: obtenerPedidos(), líneas 21–26
Future<List<Pedido>> obtenerPedidos() async {
  final r = await http.get(Uri.parse('$base/pedidos'));
  if (r.statusCode != 200) { throw Exception('Error de red'); }
  final lista = jsonDecode(r.body) as List;
  return lista.map((e) => Pedido.desdeJson(e)).toList();
}
```

### Qué se repite exactamente

Las dos funciones ejecutan el mismo algoritmo de cuatro pasos, línea por línea:

| Paso | Línea en `obtenerPlantas` | Línea en `obtenerPedidos` | ¿Idéntica? |
|---|---|---|---|
| 1. Petición GET a `$base/<recurso>` | 15 | 22 | Solo cambia la ruta |
| 2. Validar `statusCode != 200` y lanzar `Exception('Error de red')` | 16 | 23 | **Idéntica** |
| 3. Decodificar el cuerpo con `jsonDecode(r.body) as List` | 17 | 24 | **Idéntica** |
| 4. Mapear cada elemento con `<Modelo>.desdeJson(e)` y convertir a lista | 18 | 25 | Solo cambia el modelo |

Solo varían dos datos:

- **La ruta del recurso:** `plantas` o `pedidos`.
- **El constructor del modelo:** `Planta.desdeJson` o `Pedido.desdeJson`.

Todo lo demás está copiado. Si mañana la API exige un encabezado de autenticación, si hay que aceptar también el código `201` o si se quiere cambiar el mensaje de error, habría que editar cada copia. Además, cada recurso nuevo del vivero (existencias, movimientos de inventario, corte del día) agregaría otra copia de las mismas cuatro líneas.

---

## 2.2 Patrón elegido: Repository (genérico)

Separé la duplicación en dos piezas:

- **`Repositorio<T>`** (`lib/datos/repositorio.dart`): la interfaz que usan las pantallas. Tiene una sola operación, `obtenerTodos()`.
- **`RepositorioRemoto<T>`** (`lib/datos/repositorio_remoto.dart`): la única implementación del algoritmo de cuatro pasos. Recibe como parámetros las dos cosas que variaban: la ruta del recurso y la función `desdeJson`.

`ApiVivero` ya no repite código. Declara un repositorio por recurso y conserva `obtenerPlantas()` y `obtenerPedidos()` con la misma firma, así que quien ya la usaba no tiene que cambiar nada.

```dart
Repositorio<Planta> get plantas =>
    RepositorioRemoto(base, 'plantas', Planta.desdeJson);

Future<List<Planta>> obtenerPlantas() => plantas.obtenerTodos();
```

### Por qué Repository

1. **El código duplicado es acceso a datos.** La duplicación está en la capa que obtiene colecciones de la API del vivero, y centralizar ese acceso es justamente la responsabilidad de Repository. Las pantallas piden "todas las plantas" o "todos los pedidos" sin saber cómo se hace la petición.
2. **Resuelve también la restricción del caso.** Mientras no haya servidor, basta con escribir otra implementación de `Repositorio<T>` que lea datos locales, sin modificar ninguna pantalla. Con cualquier otro patrón de la lista, ese cambio de fuente de datos seguiría sin resolverse.
3. **Los recursos nuevos cuestan una línea.** Agregar existencias o el corte del día solo requiere declarar `RepositorioRemoto(base, 'existencias', Existencia.desdeJson)`, sin volver a escribir el manejo HTTP.

### Alternativas descartadas

| Alternativa | Por qué la descarté |
|---|---|
| **Adapter** | Adapter traduce una interfaz ajena e incompatible a una que el cliente espera, como hace el caso de la API de clima del tercero. Aquí no hay ninguna incompatibilidad: la API es propia del vivero y los dos métodos ya hablan el mismo contrato. Un adapter por recurso (`PlantasAdapter`, `PedidosAdapter`) simplemente movería las cuatro líneas repetidas a dos clases nuevas, y la duplicación seguiría existiendo. |
| **Strategy** | Strategy sirve para intercambiar entre varios algoritmos en tiempo de ejecución, como el cálculo de precio para cliente general, mayorista o promoción. Aquí hay **un solo** algoritmo que no cambia. Lo que varía es un dato (la ruta) y una función de conversión, no la forma de hacer la petición. Declarar una jerarquía de estrategias para eso sería sobrediseño. |
| **Factory Method** | Factory Method centraliza *qué objeto concreto se construye*. Podría encapsular la creación de `Planta` o `Pedido`, pero esa es la única línea que **no** estaba duplicada. La petición, la validación y la decodificación seguirían repetidas. |
| **Template Method** (herencia) | Una clase base con el algoritmo y subclases `RepositorioPlantas` y `RepositorioPedidos` que solo sobrescriben `desdeJson`. También eliminaría la duplicación, pero obligaría a crear una subclase por cada modelo solo para aportar una función. Pasar la función como parámetro a un repositorio genérico logra lo mismo con menos código y sin herencia. |
| **Observer** | Observer resuelve las notificaciones entre componentes, como avisar al carrito y a la barra inferior cuando se confirma un pedido. No tiene relación con código de acceso a datos repetido. |

---

## 2.3 Resultado de la refactorización

| Archivo | Cambio |
|---|---|
| `lib/datos/repositorio.dart` | **Nuevo.** Interfaz `Repositorio<T>`. |
| `lib/datos/repositorio_remoto.dart` | **Nuevo.** Una sola copia del algoritmo GET → validar → decodificar → mapear. |
| `lib/datos/api_vivero.dart` | Sin lógica HTTP. Declara los repositorios de plantas y pedidos y conserva `obtenerPlantas()` y `obtenerPedidos()` con la misma firma. |
| `lib/vivero_xochicalco.dart` | Exporta las dos clases nuevas. |

### Comportamiento intacto

Las pruebas de `test/api_vivero_test.dart` se escribieron **antes** de refactorizar (commit `09e593a`) y **no se modificaron** después. Verifican:

- que cada método consulta exactamente `$base/plantas` o `$base/pedidos`;
- que cada elemento del JSON se convierte en `Planta` o `Pedido` con sus valores;
- que un estado distinto de 200 lanza `Exception('Error de red')` con el mismo mensaje.

Para verificarlo:

```bash
dart pub get
dart analyze   # No issues found!
dart test      # All tests passed! (4 pruebas)
```

Las mismas 4 pruebas pasan en el commit original y en el commit refactorizado.
