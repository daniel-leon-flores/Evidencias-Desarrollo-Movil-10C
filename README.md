# Práctica 1 — Patrones de diseño del proyecto móvil

**Universidad Tecnológica Emiliano Zapata del Estado de Morelos**
División Académica de Tecnologías de la Información y Diseño

| | |
|---|---|
| **Asignatura** | Desarrollo Móvil Integral |
| **Unidad** | I. Definición del proceso de desarrollo móvil (semana 2) |
| **Docente** | Ing. Maximiliano Carsi Castrejón |
| **Grupo** | 10° A |
| **Modalidad** | Individual, sobre el proyecto del equipo |

---

## Contexto del caso

El **Vivero Xochicalco**, en Temixco, vende plantas de ornato, sustratos y macetas. Hoy anota sus pedidos en una libreta y consulta las existencias de memoria. Su encargada, Aurora Belmonte, quiere una aplicación móvil para levantar pedidos desde el mostrador y desde el teléfono del cliente.

Restricciones técnicas del caso:

- El catálogo y las existencias vienen de una **API propia del vivero**.
- El pronóstico de riego viene de una **API de clima de un tercero**. El equipo no controla su contrato de datos, y ese contrato ya cambió una vez sin aviso.
- Durante las primeras semanas **no habrá servidor**, así que la aplicación debe poder probarse con datos locales.

### Requisitos por rol

**Cliente**
- Consulta el catálogo de plantas con su precio y su disponibilidad.
- Arma un pedido con varias partidas y consulta su estado.
- Ve la recomendación de riego de la planta que está mirando.

**Encargada del vivero**
- Registra entradas y salidas de existencias.
- Confirma o rechaza pedidos. Al confirmar uno, se actualizan el contador del carrito, la lista de pedidos y el indicador de la barra inferior.
- Consulta el corte del día.

---

## Estructura de la práctica (100 puntos)

| Parte | Contenido | Puntos | Dónde se entrega |
|---|---|---|---|
| **I. Escrito** | Opción múltiple, clasificación de patrones por familia, propuesta de patrones para el proyecto y argumento de la segunda mejor opción | 60 | Google Classroom |
| **II. Entregable práctico** | Detectar código duplicado y eliminarlo con el patrón adecuado | 40 | Este repositorio, rama `s02-patrones` |

La práctica solo se califica si se entregan las dos partes. **Este repositorio contiene únicamente la Parte II.**

---

## Parte II. Entregable práctico

### Código de partida

El siguiente fragmento pertenece a la capa de datos de la aplicación del vivero:

```dart
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
```

Las dos funciones repiten los mismos pasos: la petición GET, la validación del código de estado, la decodificación del JSON y el mapeo de la lista. Solo cambian el endpoint y el constructor del modelo.

### Entregables

| # | Entregable | Puntos |
|---|---|---|
| 2.1 | Archivo `hallazgos.md` que señale los dos fragmentos duplicados: archivo, función y qué se repite exactamente | 10 |
| 2.2 | En el mismo `hallazgos.md`: el patrón que elimina la duplicación y por qué se eligió ese y no otro, mencionando al menos una alternativa descartada | 10 |
| 2.3 | Código refactorizado que compila, sin la duplicación y con el mismo comportamiento | 15 |
| 2.4 | Commit en la rama `s02-patrones` cuyo mensaje nombre el patrón aplicado y el componente afectado | 5 |

### Hoja de verificación

El docente revisa el repositorio directamente y comprueba lo siguiente:

- [ ] Existe la rama `s02-patrones`.
- [ ] `hallazgos.md` existe y nombra el archivo y la función de los dos fragmentos.
- [ ] La justificación del patrón menciona una alternativa descartada.
- [ ] El proyecto compila después de la refactorización.
- [ ] La duplicación señalada ya no aparece en el código entregado.
- [ ] El comportamiento observable de la aplicación es el mismo que antes de refactorizar.
- [ ] El mensaje del commit nombra el patrón aplicado y el componente afectado.

---

## Organización del repositorio

| Rama | Contenido |
|---|---|
| `main` | Este README con la descripción de la actividad |
| `s02-patrones` | `hallazgos.md`, el código original de la capa de datos y su refactorización |

Para revisar el entregable:

```bash
git checkout s02-patrones
```

---

## Patrones del temario

| Patrón | Familia | Problema que resuelve en el caso del vivero |
|---|---|---|
| Factory Method | Creacional | Delega en una subclase la decisión de qué objeto concreto construir |
| Adapter | Estructural | Aísla la app de los cambios de contrato de la API de clima |
| Repository | Acceso a datos | Permite cambiar entre datos locales y la API del vivero sin tocar las pantallas |
| Strategy | Comportamiento | Reemplaza los condicionales anidados del cálculo de precio (general, mayorista, promoción) |
| Observer | Comportamiento | Notifica al carrito, la lista de pedidos y la barra inferior cuando se confirma un pedido |
