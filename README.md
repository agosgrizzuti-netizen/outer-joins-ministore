# union-retailchain

Práctica de UNION y UNION ALL sobre el inventario de dos sucursales
(Norte y Sur) de **RetailChain**. El objetivo es distinguir cuándo
conviene un catálogo deduplicado (UNION) y cuándo se necesita el total
real de registros físicos, incluyendo duplicados (UNION ALL).

## Estructura

```
union-retailchain/
├── schema.sql       # Tablas de inventario por sucursal + datos de prueba
├── soluciones.sql   # Las 3 consultas: UNION, UNION ALL y comparación
└── README.md        # Este archivo
```

## Preguntas

### 1. ¿Cuántas filas devuelve cada consulta y por qué son distintas?

La Consulta 1 (UNION) devuelve **11 filas** y la Consulta 2 (UNION ALL)
devuelve **14 filas**. La diferencia de 3 filas se explica por los
productos que existen en ambas sucursales con exactamente el mismo
`id_producto`, `nombre_producto` y `categoria`: el **103 (Monitor 4K
27")**, el **104 (Teclado Mecánico)** y el **106 (SSD Externo 1TB)**.

En la Consulta 1 elegí no incluir la columna `stock` justamente para que
esos tres productos se reconozcan como la misma fila en ambas sucursales
(aunque tengan distinto stock) y UNION los colapse en un solo registro
por producto. Por ejemplo, el Monitor 4K aparece como `(103, 'Monitor 4K
27"', 'Computación', 5)` en Norte y `(103, 'Monitor 4K 27"',
'Computación', 3)` en Sur — el stock es distinto, pero al no
seleccionarlo, las dos filas quedan idénticas (`103, Monitor 4K 27",
Computación`) y UNION las funde en una sola. Lo mismo pasa con el
Teclado Mecánico y el SSD Externo. Esas 3 fusiones son justamente las
que explican la diferencia de 14 a 11 filas.

Vale aclarar un caso que a primera vista parece duplicado y no lo es: la
Webcam HD 1080p aparece en las dos sucursales, pero con `id_producto`
107 en Norte y 111 en Sur. Como el id es distinto, UNION las trata como
dos productos distintos y las dos quedan en el resultado — el nombre
igual no alcanza para que se consideren duplicadas.

### 2. ¿Por qué UNION ALL es más eficiente que UNION? ¿Qué operación adicional hace UNION?

`UNION ALL` simplemente concatena los resultados de ambas consultas, sin
ningún paso extra. `UNION`, en cambio, tiene que además **detectar y
eliminar duplicados**, lo que en la práctica implica ordenar (o
construir una estructura tipo hash) sobre todas las filas combinadas
para poder comparar cuáles son idénticas entre sí. Ese paso de
deduplicación es una operación adicional de ordenamiento/agrupamiento
que consume CPU y memoria, y que crece en costo a medida que crecen las
tablas. Por eso, cuando sabemos que no puede haber duplicados o no nos
importa que existan, conviene usar `UNION ALL`: se ahorra por completo
ese paso.

### 3. ¿En qué casos de negocio usaría cada uno?

**UNION** (necesito una lista limpia, sin repetir conceptos):
- Consolidar una lista de clientes que están tanto en la base de un
  sistema de e-commerce como en la de un sistema de tienda física, para
  armar un mailing único sin mandarle dos veces el mismo mail a la misma
  persona.
- Armar el listado único de todas las sucursales o depósitos que
  aparecen mencionados en distintas tablas de operaciones (por ejemplo,
  tabla de pedidos y tabla de devoluciones), para saber con cuántos
  puntos físicos distintos trabaja la empresa en total.

**UNION ALL** (necesito el volumen real, cada registro cuenta):
- Consolidar las transacciones de venta de varias sucursales o
  plataformas (local, e-commerce, marketplace) para calcular la
  facturación total del mes: acá cada venta es un evento real y no hay
  que perder ninguna, aunque dos ventas tengan exactamente el mismo
  monto y producto.
- Unificar los logs de errores de varios servidores para contar cuántos
  incidentes hubo en total: si dos servidores tuvieron el mismo error
  exacto a la misma hora (incluso coincidencia total de columnas), siguen
  siendo dos incidentes distintos y no uno solo.

### 4. ¿Qué pasa si las columnas no coinciden en número o tipo?

Si la cantidad de columnas no coincide entre las dos partes del UNION,
SQL devuelve un error de sintaxis/compilación indicando que ambas
consultas deben tener el mismo número de columnas (por ejemplo, en
PostgreSQL: `each UNION query must have the same number of columns`).
No llega a ejecutarse ni devuelve resultados parciales: el motor rechaza
la consulta completa.

Si el número de columnas coincide pero los tipos de dato no son
compatibles entre sí (por ejemplo, una columna `INT` contra una columna
`VARCHAR` con texto que no se puede convertir a número), el motor va a
intentar una conversión implícita de tipos cuando sea posible; si no es
posible, también devuelve un error de tipos incompatibles. Por eso es
tan importante que, al escribir un UNION, la cantidad de columnas y su
orden coincidan exactamente entre ambos SELECT, como hice en este
ejercicio seleccionando `id_producto, nombre_producto, categoria` (y en
la Consulta 2 sumando `stock`) en el mismo orden en ambas sucursales.
