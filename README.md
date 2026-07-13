# outer-joins-ministore

Práctica de LEFT, RIGHT y FULL OUTER JOIN sobre el catálogo de productos y el
historial de ventas de **MiniStore**, una tienda minorista. El objetivo es
detectar productos sin ventas y ventas con productos inexistentes en el
catálogo (posibles errores de carga de datos).

## Estructura

```
outer-joins-ministore/
├── schema.sql       # Tablas productos y ventas + datos de prueba
├── soluciones.sql   # Las 3 consultas con outer joins
└── README.md        # Este archivo
```

Para probarlo: cargar `schema.sql` en el motor de base de datos elegido y
después ejecutar las consultas de `soluciones.sql`.

## Preguntas

### 1. ¿Por qué usé LEFT JOIN para la Consulta 1 y no INNER JOIN? ¿Qué se perdería con INNER JOIN?

La pregunta de negocio es "¿qué productos nunca fueron vendidos?". Para
responder eso necesito partir de la tabla `productos` completa y ver, para
cada producto, si tiene o no una venta asociada. Un `INNER JOIN` solo
devuelve las filas donde hay coincidencia en ambas tablas, así que un
producto sin ventas directamente desaparecería del resultado en lugar de
aparecer con `NULL`.

Con los datos de prueba, un `INNER JOIN` entre `productos` y `ventas` deja
afuera a **Hub USB-C 7p** (id 108) y **Parlante Bluetooth** (id 109), porque
ninguno tiene un registro en `ventas`. Si usara ese join no tendría forma de
detectarlos: simplemente no estarían en el resultado, y no hay "ausencia
visible" para filtrar. El `LEFT JOIN` en cambio conserva todas las filas de
`productos` (la tabla de la izquierda) y completa con `NULL` las columnas de
`ventas` cuando no hay coincidencia, que es exactamente la señal que necesito.

### 2. ¿Por qué usé RIGHT JOIN para la Consulta 2? ¿Qué tabla está a la izquierda y cuál a la derecha?

En mi consulta, `productos` está a la izquierda (`FROM productos p`) y
`ventas` está a la derecha (`RIGHT JOIN ventas v`). Elegí `RIGHT JOIN`
porque la pregunta de negocio esta vez pide lo contrario a la Consulta 1:
quiero conservar todas las filas de `ventas`, aunque su `producto_id` no
exista en `productos`. Como `ventas` es la tabla del lado derecho del join,
`RIGHT JOIN` es el que garantiza que ninguna venta se pierda, incluso las que
tienen un producto inexistente.

Podría haber escrito lo mismo como `ventas v LEFT JOIN productos p`
(invirtiendo el orden y el tipo de join), que da un resultado equivalente.
Lo importante es que la tabla cuyas filas quiero conservar completas sea la
que queda del lado que corresponde al join elegido.

### 3. ¿Qué representan los valores NULL en cada resultado?

En ambos casos, un `NULL` no es un dato faltante por error de mi consulta:
es la forma en que SQL me avisa "no hay ninguna fila que haga match del otro
lado".

- **Consulta 1 (LEFT JOIN):** cuando `venta_id` es `NULL`, significa que ese
  producto del catálogo no tiene ninguna fila asociada en `ventas`. Por
  ejemplo, para el producto 108 (Hub USB-C 7p), `venta_id`, `cantidad` y
  `fecha_venta` aparecen como `NULL` porque, revisando los datos de prueba,
  nunca se insertó una venta con `producto_id = 108`. El `NULL` ahí significa
  literalmente "0 ventas registradas para este producto".

- **Consulta 2 (RIGHT JOIN):** cuando `producto_id` de la tabla `productos`
  es `NULL`, significa que esa venta hace referencia a un producto que no
  existe en el catálogo. La venta 10 tiene `producto_id = 999` en la tabla
  `ventas`, pero en `productos` no existe ningún registro con ese id (el
  catálogo llega hasta el 109). El `NULL` en `nombre` y `categoria` no
  significa que el producto "no tenga nombre": significa que esa fila de
  `productos` no existe, es un indicio de una venta mal cargada o de un
  producto que fue dado de baja del catálogo sin avisar.

### 4. ¿Cuándo usaría FULL OUTER JOIN en un caso real de negocio?

Usaría `FULL OUTER JOIN` en cualquier escenario de **auditoría o
conciliación de datos**, donde necesito ver los dos lados del problema al
mismo tiempo sin perder ninguna fila de ninguna de las dos tablas. En este
ejercicio, la Consulta 3 sirve justamente para eso: en un solo resultado
puedo ver tanto los productos sin ventas como las ventas sin producto,
sin tener que correr dos consultas separadas.

Otros casos reales donde lo usaría:

- Conciliar un sistema de facturación contra un sistema de pagos, para
  detectar facturas sin pago registrado y pagos sin factura asociada.
- Cruzar una lista de empleados contra los accesos otorgados en un sistema,
  para encontrar empleados sin acceso y accesos activos de gente que ya no
  está en la empresa.
- Migrar datos entre dos sistemas y verificar qué registros existen en uno
  pero no en el otro, en ambas direcciones, antes de dar por cerrada la
  migración.

En general, lo reservaría para instancias de auditoría puntuales más que
para reportes que se corren todos los días, porque suele ser una consulta
más pesada que un `INNER` o un `LEFT/RIGHT JOIN` simple.
