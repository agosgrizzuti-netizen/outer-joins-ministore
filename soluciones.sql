-- ══════════════════════════════════════════
-- MiniStore — Soluciones con Outer JOINs
-- Autor: [Tu nombre]
-- Fecha: [Fecha de entrega]
-- ══════════════════════════════════════════

-- ── CONSULTA 1: LEFT JOIN ─────────────────
-- Pregunta de negocio: ¿Qué productos del catálogo nunca fueron vendidos?
-- Mostramos todos los productos y sus ventas asociadas.
-- Los productos sin ventas aparecen con NULL en las columnas de ventas.

SELECT p.producto_id,
       p.nombre,
       p.categoria,
       v.venta_id,
       v.cantidad,
       v.fecha_venta
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY p.producto_id;
-- Devuelve los 9 productos del catálogo; los 2 que nunca se vendieron
-- (108 Hub USB-C y 109 Parlante Bluetooth) muestran NULL en venta_id,
-- cantidad y fecha_venta.

-- Versión filtrada: aísla directamente la respuesta a la pregunta de negocio
-- (qué productos nunca fueron vendidos), usando el NULL como condición.
SELECT p.producto_id,
       p.nombre,
       p.categoria
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL
ORDER BY p.producto_id;


-- ── CONSULTA 2: RIGHT JOIN ────────────────
-- Pregunta de negocio: ¿Existen ventas registradas con productos
-- que no figuran en nuestro catálogo? (posible error de carga de datos)
-- La tabla de la izquierda es productos y la de la derecha es ventas,
-- por eso el RIGHT JOIN devuelve todas las filas de ventas aunque no
-- tengan producto asociado en el catálogo.

SELECT v.venta_id,
       v.producto_id AS producto_id_en_venta,
       v.cliente_id,
       v.cantidad,
       v.fecha_venta,
       p.nombre,
       p.categoria
FROM productos p
RIGHT JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY v.venta_id;
-- Devuelve las 10 ventas; la venta 10 (producto_id 999) muestra NULL
-- en nombre y categoria porque ese producto no existe en el catálogo.

-- Versión filtrada: aísla directamente el registro huérfano.
SELECT v.venta_id,
       v.producto_id AS producto_id_en_venta,
       v.cliente_id,
       v.cantidad,
       v.fecha_venta
FROM productos p
RIGHT JOIN ventas v ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
ORDER BY v.venta_id;


-- ── CONSULTA 3: FULL OUTER JOIN ───────────
-- Pregunta de negocio: vista completa de auditoría que muestre
-- todos los productos y todas las ventas sin perder ninguna fila,
-- identificando tanto productos sin ventas como ventas sin producto.
-- Nota: MySQL no soporta FULL OUTER JOIN de forma nativa; si se usa
-- MySQL, esta consulta se simula con LEFT JOIN UNION RIGHT JOIN
-- (ver alternativa comentada más abajo).

SELECT p.producto_id,
       p.nombre,
       p.categoria,
       v.venta_id,
       v.producto_id AS producto_id_en_venta,
       v.cantidad,
       v.fecha_venta
FROM productos p
FULL OUTER JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;
-- Muestra las 12 filas resultantes: todas las combinaciones producto-venta
-- que coinciden, más los 2 productos nunca vendidos, más la venta huérfana
-- (producto_id 999). No se pierde ninguna fila de ninguna de las dos tablas.

-- Alternativa equivalente para motores sin soporte nativo de FULL OUTER JOIN (ej. MySQL):
-- SELECT p.producto_id, p.nombre, p.categoria, v.venta_id, v.producto_id AS producto_id_en_venta, v.cantidad, v.fecha_venta
-- FROM productos p
-- LEFT JOIN ventas v ON p.producto_id = v.producto_id
-- UNION
-- SELECT p.producto_id, p.nombre, p.categoria, v.venta_id, v.producto_id AS producto_id_en_venta, v.cantidad, v.fecha_venta
-- FROM productos p
-- RIGHT JOIN ventas v ON p.producto_id = v.producto_id;
