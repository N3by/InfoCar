-- init.sql
-- Crea la base y usa el esquema
DROP DATABASE IF EXISTS transito_db;
CREATE DATABASE transito_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE transito_db;

-- =========================
-- Tablas
-- =========================
CREATE TABLE propietario (
  id_propietario INT AUTO_INCREMENT PRIMARY KEY,
  cedula VARCHAR(20) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  direccion VARCHAR(200),
  telefono VARCHAR(30),
  email VARCHAR(120),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehiculo (
  id_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
  placa VARCHAR(10) NOT NULL UNIQUE,
  marca VARCHAR(50),
  modelo YEAR,
  tipo VARCHAR(30),           -- carro, moto, camioneta...
  cilindraje INT,
  estado_soat ENUM('VIGENTE','VENCIDO') NOT NULL,
  vencimiento_soat DATE NOT NULL,
  estado_tecnomecanica ENUM('VIGENTE','VENCIDO') NOT NULL,
  vencimiento_tecnomecanica DATE NOT NULL,
  id_propietario INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vehiculo_propietario
    FOREIGN KEY (id_propietario) REFERENCES propietario(id_propietario)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE multas (
  id_multa INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATE NOT NULL,
  tipo_infraccion VARCHAR(120) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  estado ENUM('PAGADA','PENDIENTE','EN_COBRO') NOT NULL DEFAULT 'PENDIENTE',
  id_vehiculo INT NOT NULL,
  id_propietario INT,         -- opcional: multas al conductor/propietario
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_multa_vehiculo
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_multa_propietario
    FOREIGN KEY (id_propietario) REFERENCES propietario(id_propietario)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE historial_propietarios (
  id_historial INT AUTO_INCREMENT PRIMARY KEY,
  id_vehiculo INT NOT NULL,
  cedula_antiguo_propietario VARCHAR(20) NOT NULL,
  fecha_transferencia DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hist_vehiculo
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE seguros_alertas (
  id_alerta INT AUTO_INCREMENT PRIMARY KEY,
  id_propietario INT NOT NULL,
  id_vehiculo INT NOT NULL,
  tipo_alerta ENUM('SOAT','TECNOMECANICA') NOT NULL,
  dias_restantes INT NOT NULL,
  notificado BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_alerta_prop
    FOREIGN KEY (id_propietario) REFERENCES propietario(id_propietario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_alerta_veh
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Índices útiles
CREATE INDEX idx_propietario_cedula ON propietario(cedula);
CREATE INDEX idx_vehiculo_placa ON vehiculo(placa);
CREATE INDEX idx_multa_estado ON multas(estado);
CREATE INDEX idx_alerta_tipo ON seguros_alertas(tipo_alerta);

-- =========================
-- Datos dummy (100 filas total)
-- =========================

-- 1) 30 propietarios
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 30
)
INSERT INTO propietario (cedula, nombre, direccion, telefono, email)
SELECT
  CONCAT('10', LPAD(n, 8, '0')) AS cedula,
  CONCAT('Propietario ', n) AS nombre,
  CONCAT('Calle ', n, ' #', n, '-', (n%50)+1, ' Bogotá') AS direccion,
  CONCAT('+57 300', LPAD(n, 7, '0')) AS telefono,
  CONCAT('prop', n, '@mail.com') AS email
FROM seq;

-- 2) 35 vehículos (asignados cíclicamente a 30 propietarios)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 35
)
INSERT INTO vehiculo (
  placa, marca, modelo, tipo, cilindraje,
  estado_soat, vencimiento_soat,
  estado_tecnomecanica, vencimiento_tecnomecanica,
  id_propietario
)
SELECT
  CONCAT('ABC', LPAD(n,3,'0')) AS placa,
  ELT((n%6)+1, 'Chevrolet','Renault','Yamaha','Kia','Mazda','Honda') AS marca,
  2000 + (n%24) AS modelo,
  ELT((n%3)+1, 'carro','moto','camioneta') AS tipo,
  CASE WHEN (n%3)=2 THEN 125 ELSE CASE WHEN (n%3)=1 THEN 1600 ELSE 2000 END END AS cilindraje,
  IF((n%4)=0,'VENCIDO','VIGENTE') AS estado_soat,
  DATE_ADD(CURDATE(), INTERVAL (CASE WHEN (n%4)=0 THEN -15 ELSE (n%20)+5 END) DAY) AS venc_soat,
  IF((n%5)=0,'VENCIDO','VIGENTE') AS estado_tecnomecanica,
  DATE_ADD(CURDATE(), INTERVAL (CASE WHEN (n%5)=0 THEN -30 ELSE (n%40)+10 END) DAY) AS venc_tecno,
  ((n-1) % 30) + 1 AS id_propietario
FROM seq;

-- 3) 20 multas (ligadas a vehículo y, si aplica, al propietario actual del vehículo)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 20
)
INSERT INTO multas (fecha, tipo_infraccion, monto, estado, id_vehiculo, id_propietario)
SELECT
  DATE_ADD(CURDATE(), INTERVAL -(n*3) DAY) AS fecha,
  ELT((n%6)+1, 'Exceso de velocidad','Pico y placa','Mal estacionado','SOAT vencido','Revisión vencida','Conducir sin licencia') AS tipo_infraccion,
  (CASE (n%6)
     WHEN 0 THEN 522000
     WHEN 1 THEN 130000
     WHEN 2 THEN 327000
     WHEN 3 THEN 1040000
     WHEN 4 THEN 780000
     ELSE 989000 END) * 1.00 AS monto,
  ELT((n%3)+1, 'PENDIENTE','PAGADA','EN_COBRO') AS estado,
  ((n-1) % 35) + 1 AS id_vehiculo,
  (SELECT v.id_propietario FROM vehiculo v WHERE v.id_vehiculo = ((n-1)%35)+1) AS id_propietario
FROM seq;

-- 4) 5 historiales de propietarios (simulando transferencias previas)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 5
)
INSERT INTO historial_propietarios (id_vehiculo, cedula_antiguo_propietario, fecha_transferencia)
SELECT
  n AS id_vehiculo,
  CONCAT('10', LPAD(5000 + n, 8, '0')) AS cedula_antiguo,
  DATE_ADD(CURDATE(), INTERVAL -(200 + n*15) DAY) AS fecha_tr
FROM seq;

-- 5) 10 alertas (SOAT/TECNOMECANICA) sobre distintos vehículos/propietarios
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 10
)
INSERT INTO seguros_alertas (id_propietario, id_vehiculo, tipo_alerta, dias_restantes, notificado)
SELECT
  ((n-1)%30)+1 AS id_propietario,
  ((n-1)%35)+1 AS id_vehiculo,
  ELT((n%2)+1, 'SOAT','TECNOMECANICA') AS tipo_alerta,
  CASE WHEN (n%4)=0 THEN 0 ELSE (n*3) END AS dias_restantes,
  (n%3)=0 AS notificado
FROM seq;

-- =========================
-- Verificaciones rápidas
-- =========================
SELECT 'propietario' AS tabla, COUNT(*) AS filas FROM propietario
UNION ALL SELECT 'vehiculo', COUNT(*) FROM vehiculo
UNION ALL SELECT 'multas', COUNT(*) FROM multas
UNION ALL SELECT 'historial_propietarios', COUNT(*) FROM historial_propietarios
UNION ALL SELECT 'seguros_alertas', COUNT(*) FROM seguros_alertas;

-- Consultas de ejemplo
-- 1) Consulta por placa + cédula
-- SELECT p.nombre, v.placa, v.estado_soat, v.vencimiento_soat
-- FROM vehiculo v
-- JOIN propietario p ON p.id_propietario = v.id_propietario
-- WHERE v.placa = 'ABC005' AND p.cedula = '1000000005';

-- 2) Multas pendientes por vehículo
-- SELECT m.* FROM multas m
-- JOIN vehiculo v ON v.id_vehiculo = m.id_vehiculo
-- WHERE v.placa='ABC010' AND m.estado='PENDIENTE';

-- 3) Alertas próximas a vencer (<= 7 días)
-- SELECT a.*, p.cedula, v.placa
-- FROM seguros_alertas a
-- JOIN propietario p ON p.id_propietario=a.id_propietario
-- JOIN vehiculo v ON v.id_vehiculo=a.id_vehiculo
-- WHERE a.dias_restantes <= 7
-- ORDER BY a.dias_restantes ASC;
