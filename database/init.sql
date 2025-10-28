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
-- Datos dummy (260 filas total: 70 propietarios + 100 vehículos + 60 multas + 30 historiales)
-- =========================

-- 1) 70 propietarios con datos realistas colombianos (solo números en cédula)
INSERT INTO propietario (cedula, nombre, direccion, telefono, email)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 70
)
SELECT
  CONCAT('1234567', LPAD(n, 3, '0')) AS cedula,
  CONCAT(
    ELT((n%20)+1, 'Carlos Alberto', 'María Elena', 'Luis Fernando', 'Ana María', 'José Manuel', 
        'Laura Patricia', 'Fernando Andrés', 'Patricia Lucia', 'Miguel Ángel', 'Diana Carolina', 
        'Ricardo Antonio', 'Sandra Milena', 'Javier Eduardo', 'Carmen Rosa', 'Diego Alejandro',
        'Andrés Felipe', 'Paola Andrea', 'Juan Carlos', 'María Alejandra', 'David Santiago'),
    ' ',
    ELT((n%25)+1, 'García', 'Rodríguez', 'López', 'Martínez', 'González', 'Hernández', 'Pérez', 
        'Sánchez', 'Ramírez', 'Torres', 'Flores', 'Rivera', 'Cruz', 'Morales', 'Ortiz', 
        'Gutiérrez', 'Jiménez', 'Mendoza', 'Álvarez', 'Fernández', 'Castro', 'Vargas', 
        'Moreno', 'Ruiz', 'Díaz')
  ) AS nombre,
  CONCAT(
    ELT((n%4)+1, 'Carrera', 'Calle', 'Avenida', 'Transversal'),
    ' ',
    (n*7) % 200,
    IF(n%3=0, ' #', ''),
    IF(n%3=0, (n%50)+1, ''),
    ', Barrio ',
    ELT((n%15)+1, 'Centro', 'El Poblado', 'La Floresta', 'Los Colina', 'Alameda', 'El Nogal', 
        'La Candelaria', 'Usaquén', 'Chapinero', 'Kennedy', 'Suba', 'Engativá', 'Fontibón', 
        'Santa Fe', 'Barrios Unidos'),
    ', ',
    ELT((n%10)+1, 'Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Bucaramanga', 
        'Pereira', 'Manizales', 'Armenia', 'Pasto')
  ) AS direccion,
  CONCAT('350608', LPAD(n, 4, '0')) AS telefono,
  CONCAT(
    LOWER(ELT((n%20)+1, 'carlos', 'maria', 'luis', 'ana', 'jose', 'laura', 'fernando', 
        'patricia', 'miguel', 'diana', 'ricardo', 'sandra', 'javier', 'carmen', 'diego', 
        'andres', 'paola', 'juan', 'david', 'andrea')),
    '.',
    LOWER(ELT((n%25)+1, 'garcia', 'rodriguez', 'lopez', 'martinez', 'gonzalez', 'hernandez', 
        'perez', 'sanchez', 'ramirez', 'torres', 'flores', 'rivera', 'cruz', 'morales', 'ortiz', 
        'gutierrez', 'jimenez', 'mendoza', 'alvarez', 'fernandez', 'castro', 'vargas', 
        'moreno', 'ruiz', 'diaz')),
    IF(n%3=0, '@gmail.com', IF(n%2=0, '@hotmail.com', '@outlook.com'))
  ) AS email
FROM seq;

-- 2) 100 vehículos con placas realistas según tipo de vehículo
INSERT INTO vehiculo (
  placa, marca, modelo, tipo, cilindraje,
  estado_soat, vencimiento_soat,
  estado_tecnomecanica, vencimiento_tecnomecanica,
  id_propietario
)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 100
)
SELECT
  CASE 
    WHEN (n%4)=2 THEN -- Motos: formato ABC12A (n%4=2 es la posición de 'moto' en ELT)
      CONCAT(CHAR(65+(n%26)), CHAR(66+((n*7)%26)), CHAR(67+((n*11)%26)), LPAD(((n%99)+1), 2, '0'), CHAR(65+((n*13)%26)))
    WHEN (n%4)=0 THEN -- Busetas: formato EQA-123 (n%4=0 es la posición de 'buseta')
      CONCAT('EQA-', LPAD((n%999)+1, 3, '0'))
    ELSE -- Carros y Camionetas: formato ABC123
      CONCAT(CHAR(65+(n%26)), CHAR(66+((n*7)%26)), CHAR(67+((n*11)%26)), LPAD((n%999)+1, 3, '0'))
  END AS placa,
  ELT((n%12)+1, 'Chevrolet','Renault','Yamaha','Kia','Mazda','Honda','Toyota','Nissan','Ford','Mitsubishi','Suzuki','Hyundai') AS marca,
  2000 + (n%25) AS modelo,
  ELT((n%4)+1, 'carro','moto','camioneta','buseta') AS tipo,
  CASE 
    WHEN (n%4)=3 THEN 125  -- moto
    WHEN (n%4)=2 THEN 2500 -- camioneta
    WHEN (n%4)=0 THEN 3000 -- buseta
    ELSE 1600 -- carro
  END AS cilindraje,
  IF((n%5)=0,'VENCIDO','VIGENTE') AS estado_soat,
  DATE_ADD(CURDATE(), INTERVAL (CASE WHEN (n%5)=0 THEN -15 ELSE (n%20)+5 END) DAY) AS vencimiento_soat,
  IF((n%6)=0,'VENCIDO','VIGENTE') AS estado_tecnomecanica,
  DATE_ADD(CURDATE(), INTERVAL (CASE WHEN (n%6)=0 THEN -30 ELSE (n%40)+10 END) DAY) AS vencimiento_tecnomecanica,
  ((n-1) % 70) + 1 AS id_propietario
FROM seq;

-- 3) 60 multas con infracciones colombianas realistas
INSERT INTO multas (fecha, tipo_infraccion, monto, estado, id_vehiculo, id_propietario)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 60
)
SELECT
  DATE_ADD(CURDATE(), INTERVAL -(n*2) DAY) AS fecha,
  ELT((n%8)+1, 
    'Exceso de velocidad en zona escolar',
    'Pico y placa',
    'Estacionar en zona prohibida',
    'SOAT vencido',
    'Revisión tecnomecánica vencida',
    'Conducir sin licencia',
    'No respetar semáforo en rojo',
    'Circular sin placas'
  ) AS tipo_infraccion,
  (CASE (n%8)
     WHEN 0 THEN 522000
     WHEN 1 THEN 130000
     WHEN 2 THEN 327000
     WHEN 3 THEN 1040000
     WHEN 4 THEN 780000
     WHEN 5 THEN 989000
     WHEN 6 THEN 1045000
     ELSE 890000
   END) * 1.00 AS monto,
  ELT((n%3)+1, 'PENDIENTE','PAGADA','EN_COBRO') AS estado,
  ((n-1) % 100) + 1 AS id_vehiculo,
  (SELECT v.id_propietario FROM vehiculo v WHERE v.id_vehiculo = ((n-1)%100)+1) AS id_propietario
FROM seq;

-- 4) 30 historiales de propietarios con cédulas antiguas (solo números)
INSERT INTO historial_propietarios (id_vehiculo, cedula_antiguo_propietario, fecha_transferencia)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 30
)
SELECT
  n AS id_vehiculo,
  CONCAT('9876543', LPAD(n*7, 3, '0')) AS cedula_antiguo_propietario,
  DATE_SUB(CURDATE(), INTERVAL (200 + n*45) DAY) AS fecha_transferencia
FROM seq;

-- 5) 15 alertas (SOAT/TECNOMECANICA) sobre distintos vehículos/propietarios
INSERT INTO seguros_alertas (id_propietario, id_vehiculo, tipo_alerta, dias_restantes, notificado)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 15
)
SELECT
  ((n-1)%70)+1 AS id_propietario,
  ((n-1)%100)+1 AS id_vehiculo,
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

-- Total esperado: 275 registros (70+100+60+30+15)

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
