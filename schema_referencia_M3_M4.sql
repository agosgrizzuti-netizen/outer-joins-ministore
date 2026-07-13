-- ══════════════════════════════════════════════════
-- RetailPro — Schema de referencia (M3/M4)
-- Este archivo NO es el entregable de M5. Se incluye
-- únicamente para poder probar que las consultas de
-- m5_consultas_joins.sql corren correctamente de punta
-- a punta. Si tus tablas de M3/M4 ya existen con otros
-- nombres de columna, usá ESE schema como referencia real
-- y ajustá los nombres en m5_consultas_joins.sql.
-- ══════════════════════════════════════════════════

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS territorios;

CREATE TABLE clientes (
    cliente_id      INT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    segmento        VARCHAR(50),   -- 'Mayorista' / 'Minorista'
    fecha_registro  DATE
);

CREATE TABLE productos (
    producto_id     INT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    precio          DECIMAL(10,2)
);

CREATE TABLE territorios (
    territorio_id   INT PRIMARY KEY,
    region          VARCHAR(50),
    provincia       VARCHAR(50)
);

CREATE TABLE ventas (
    venta_id        INT PRIMARY KEY,
    cliente_id      INT,
    producto_id     INT,
    territorio_id   INT,
    fecha_venta     DATE NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_venta     DECIMAL(10,2) NOT NULL,
    canal           VARCHAR(20) NOT NULL   -- 'Online' / 'Presencial'
);

-- Clientes (incluye 2 clientes SIN ninguna compra, para la Consulta 2)
INSERT INTO clientes VALUES (1, 'Marina Gómez',      'marina.gomez@mail.com',   'Minorista', '2023-02-10');
INSERT INTO clientes VALUES (2, 'Carlos Fernández',  'carlos.fdz@mail.com',     'Mayorista', '2023-03-15');
INSERT INTO clientes VALUES (3, 'Lucía Torres',       'lucia.torres@mail.com',  'Minorista', '2023-05-22');
INSERT INTO clientes VALUES (4, 'Distribuidora Sur SA','compras@dsur.com',      'Mayorista', '2023-06-01');
INSERT INTO clientes VALUES (5, 'Javier Ríos',        'javier.rios@mail.com',  'Minorista', '2024-01-09');
INSERT INTO clientes VALUES (6, 'Norma Aguirre',      'norma.aguirre@mail.com','Minorista', '2024-02-14'); -- sin compras
INSERT INTO clientes VALUES (7, 'TecnoWholesale SRL', 'ventas@tecnowholesale.com','Mayorista','2024-03-01'); -- sin compras

-- Productos (incluye 2 productos SIN ninguna venta, para la Consulta 3)
INSERT INTO productos VALUES (101, 'Laptop Pro 15',      'Computación',    1200.00);
INSERT INTO productos VALUES (102, 'Mouse Inalámbrico',  'Accesorios',       28.00);
INSERT INTO productos VALUES (103, 'Monitor 4K 27"',     'Computación',     450.00);
INSERT INTO productos VALUES (104, 'Teclado Mecánico',   'Accesorios',       95.00);
INSERT INTO productos VALUES (105, 'Auriculares BT Pro', 'Audio',           120.00);
INSERT INTO productos VALUES (106, 'SSD Externo 1TB',    'Almacenamiento',  130.00);
INSERT INTO productos VALUES (107, 'Hub USB-C 7p',       'Accesorios',       45.00); -- sin ventas
INSERT INTO productos VALUES (108, 'Parlante Bluetooth', 'Audio',            60.00); -- sin ventas

-- Territorios
INSERT INTO territorios VALUES (1, 'Norte', 'Salta');
INSERT INTO territorios VALUES (2, 'Sur',   'Chubut');
INSERT INTO territorios VALUES (3, 'Centro','Córdoba');

-- Ventas (mezcla de canal Online y Presencial, y de regiones)
INSERT INTO ventas VALUES (1,  1, 101, 1, '2024-01-05', 2, 1200.00, 2400.00, 'Online');
INSERT INTO ventas VALUES (2,  2, 102, 2, '2024-01-08', 5,   28.00,  140.00, 'Presencial');
INSERT INTO ventas VALUES (3,  3, 103, 3, '2024-01-12', 1,  450.00,  450.00, 'Online');
INSERT INTO ventas VALUES (4,  1, 101, 1, '2024-02-03', 1, 1200.00, 1200.00, 'Presencial');
INSERT INTO ventas VALUES (5,  4, 104, 2, '2024-02-10', 3,   95.00,  285.00, 'Online');
INSERT INTO ventas VALUES (6,  2, 105, 1, '2024-02-18', 2,  120.00,  240.00, 'Presencial');
INSERT INTO ventas VALUES (7,  5, 106, 3, '2024-03-05', 3,  130.00,  390.00, 'Online');
INSERT INTO ventas VALUES (8,  3, 102, 2, '2024-03-12', 8,   28.00,  224.00, 'Presencial');
INSERT INTO ventas VALUES (9,  4, 103, 1, '2024-03-20', 2,  450.00,  900.00, 'Online');
INSERT INTO ventas VALUES (10, 5, 104, 3, '2024-03-25', 4,   95.00,  380.00, 'Presencial');
