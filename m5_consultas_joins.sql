-- ══════════════════════════════════════════════════
-- RetailPro — M5: Consultas con JOINs para el proyecto
-- Autor: [Tu nombre]
-- Fecha: [Fecha de entrega]
--
-- Estas consultas asumen las tablas creadas en M3/M4:
--   clientes    (cliente_id, nombre, email, segmento, fecha_registro)
--   productos   (producto_id, nombre, categoria, precio)
--   territorios (territorio_id, region, provincia)
--   ventas      (venta_id, cliente_id, producto_id, territorio_id,
--                fecha_venta, cantidad, precio_unitario, total_venta, canal)
--
-- Si tus tablas de M3/M4 usan otros nombres de columna, ajustalos acá
-- antes de correr este archivo.
-- ══════════════════════════════════════════════════


-- ── CONSULTA 1: Vista base del proyecto (INNER JOIN) ─────────
-- Cruza ventas + clientes + productos + territorios en una sola fila.
-- Esta es la vista que va a alimentar el modelo de Power BI en M7.

SELECT
    v.fecha_venta,
    c.nombre        AS nombre_cliente,
    c.segmento,
    t.region,
    p.nombre        AS nombre_producto,
    p.categoria,
    v.cantidad,
    v.precio_unitario,
    v.total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes    c ON v.cliente_id    = c.cliente_id
INNER JOIN productos   p ON v.producto_id   = p.producto_id
INNER JOIN territorios t ON v.territorio_id = t.territorio_id
ORDER BY v.fecha_venta;


-- ── CONSULTA 2: Clientes sin ventas (LEFT JOIN) ───────────────
-- Pregunta de negocio (CRM): ¿qué clientes registrados nunca compraron?
-- El LEFT JOIN conserva todos los clientes; el WHERE aísla los que
-- no tienen ninguna venta asociada (venta_id NULL).

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL
ORDER BY c.fecha_registro;


-- ── CONSULTA 3: Productos sin ventas (LEFT JOIN) ──────────────
-- Pregunta de negocio (Producto): ¿qué artículos del catálogo no
-- tienen ningún movimiento? El LEFT JOIN conserva todos los productos;
-- el WHERE aísla los que no tienen ninguna venta asociada.

SELECT
    p.nombre,
    p.categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL
ORDER BY p.nombre;


-- ── CONSULTA 4: Consolidado por canal (UNION ALL) ─────────────
-- Combina las ventas Online y Presencial en un único resultado,
-- etiquetando cada fila con su canal de origen, y calcula el total
-- facturado y la cantidad de ventas por canal.

SELECT
    canal,
    SUM(total_venta)  AS total_facturado,
    COUNT(*)           AS cantidad_ventas
FROM (
    SELECT 'Online' AS canal, total_venta
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT 'Presencial' AS canal, total_venta
    FROM ventas
    WHERE canal = 'Presencial'
) AS ventas_consolidadas
GROUP BY canal
ORDER BY canal;
