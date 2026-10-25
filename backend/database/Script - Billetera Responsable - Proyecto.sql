-- Paso 1. Crear bases de datos
DROP DATABASE IF EXISTS BilleteraOLTP;
DROP DATABASE IF EXISTS BilleteraDW;

CREATE DATABASE BilleteraOLTP;
USE BilleteraOLTP;

CREATE TABLE Usuario (
    IdUsuario INT PRIMARY KEY,
    Edad INT,
    Sexo VARCHAR(20),
    Rol VARCHAR(20),
    FechaIntervencionRAG DATE
);

CREATE TABLE Categoria (
    IdCategoria INT PRIMARY KEY,
    NombreCategoria VARCHAR(100),
    TipoCategoria VARCHAR(50)
);

CREATE TABLE MedioPago (
    IdMedioPago INT PRIMARY KEY,
    CanalPago VARCHAR(50),
    TipoCanal VARCHAR(50)
);

CREATE TABLE Transaccion (
    IdTransaccion INT AUTO_INCREMENT PRIMARY KEY,
    IdUsuario INT,
    IdCategoria INT,
    IdMedioPago INT,
    FechaHora DATETIME,
    MontoIngreso DECIMAL(10,2),
    MontoGasto DECIMAL(10,2),
    MontoAhorro DECIMAL(10,2),
    MontoDeuda DECIMAL(10,2)
);

-- Crear Data Warehouse
CREATE DATABASE BilleteraDW;
USE BilleteraDW;

CREATE TABLE dim_usuario (
    id_usuario INT PRIMARY KEY,
    edad INT,
    sexo VARCHAR(20),
    rol VARCHAR(20),
    fecha_intervencion_rag DATE
);

CREATE TABLE dim_categoria (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(100),
    tipo_categoria VARCHAR(50)
);

CREATE TABLE dim_mediopago (
    id_medio_pago INT PRIMARY KEY,
    canal_pago VARCHAR(50),
    tipo_canal VARCHAR(50)
);

CREATE TABLE dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE,
    mes INT,
    trimestre INT,
    anio INT
);

CREATE TABLE dim_estadofinanciero (
    id_estado INT PRIMARY KEY,
    estado VARCHAR(20),
    descripcion VARCHAR(255)
);

CREATE TABLE dim_rangomonto (
    id_rango INT PRIMARY KEY,
    rango_gasto VARCHAR(20),
    monto_minimo DECIMAL(10,2),
    monto_maximo DECIMAL(10,2)
);

CREATE TABLE fact_finanzas (
    id_transaccion INT PRIMARY KEY,
    id_usuario INT,
    id_categoria INT,
    id_medio_pago INT,
    id_tiempo INT,
    id_estado INT,
    id_rango INT,
    fecha_hora DATETIME,
    monto_ingreso DECIMAL(10,2),
    monto_gasto DECIMAL(10,2),
    monto_ahorro DECIMAL(10,2),
    monto_deuda DECIMAL(10,2),
    ratio_endeudamiento DECIMAL(5,2),
    probabilidad_riesgo DECIMAL(5,4),
    es_prediccion_correcta INT,
    FOREIGN KEY (id_usuario) REFERENCES dim_usuario(id_usuario),
    FOREIGN KEY (id_categoria) REFERENCES dim_categoria(id_categoria),
    FOREIGN KEY (id_medio_pago) REFERENCES dim_mediopago(id_medio_pago),
    FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo),
    FOREIGN KEY (id_estado) REFERENCES dim_estadofinanciero(id_estado),
    FOREIGN KEY (id_rango) REFERENCES dim_rangomonto(id_rango)
);

USE BilleteraOLTP;

-- Insertar Categorías
INSERT INTO Categoria VALUES
(1, 'Alimentación', 'Gasto Fijo'),
(2, 'Transporte', 'Gasto Fijo'),
(3, 'Entretenimiento', 'Gasto Discrecional'),
(4, 'Salud y Cuidado', 'Gasto Necesario'),
(5, 'Educación', 'Gasto Necesario'),
(6, 'Ropa y Calzado', 'Gasto Discrecional'),
(7, 'Pago de Servicios', 'Gasto Fijo'),
(8, 'Otros Gastos', 'Gasto Discrecional');

-- Insertar Medios de Pago
INSERT INTO MedioPago VALUES
(1, 'Yape', 'Billetera Digital'),
(2, 'Plin', 'Billetera Digital'),
(3, 'Efectivo', 'Tradicional');

-- Insertar Usuarios con Fecha de Intervención RAG (Julio 2026)
INSERT INTO Usuario VALUES
(1001, 21, 'F', 'Usuario', '2026-07-01'),
(1002, 28, 'M', 'Usuario', '2026-07-01'),
(1003, 22, 'M', 'Usuario', '2026-07-01'),
(1004, 20, 'F', 'Usuario', '2026-07-01'),
(1005, 19, 'M', 'Usuario', '2026-07-01'),
(1006, 24, 'F', 'Usuario', '2026-07-01'),
(1007, 30, 'M', 'Usuario', '2026-07-01'),
(1008, 20, 'M', 'Usuario', '2026-07-01'),
(1009, 23, 'F', 'Usuario', '2026-07-01'),
(1010, 21, 'M', 'Usuario', '2026-07-01'),
(1011, 25, 'F', 'Usuario', '2026-07-01'),
(1012, 22, 'F', 'Usuario', '2026-07-01'),
(1013, 19, 'F', 'Usuario', '2026-07-01'),
(1014, 21, 'F', 'Usuario', '2026-07-01'),
(1015, 26, 'M', 'Usuario', '2026-07-01'),
(1016, 21, 'F', 'Usuario', '2026-07-01'),
(1017, 27, 'F', 'Usuario', '2026-07-01'),
(1018, 18, 'F', 'Usuario', '2026-07-01'),
(1019, 21, 'F', 'Usuario', '2026-07-01'),
(1020, 21, 'M', 'Usuario', '2026-07-01');

-- GENERAR 1 TRANSACCIÓN POR DÍA CON UN PROCEDIMIENTO ALMACENADO
DELIMITER //
CREATE PROCEDURE PoblarTransacciones()
BEGIN
    DECLARE v_FechaActual DATE DEFAULT '2026-01-01';
    DECLARE v_FechaFin DATE DEFAULT '2026-10-31';
    DECLARE v_AhorroGenerado DECIMAL(10,2);

    WHILE v_FechaActual <= v_FechaFin DO
        IF v_FechaActual >= '2026-07-01' THEN
            SET v_AhorroGenerado = 200 + FLOOR(RAND() * 250);
        ELSE
            SET v_AhorroGenerado = 50 + FLOOR(RAND() * 100);
        END IF;

        INSERT INTO Transaccion (
            IdUsuario, IdCategoria, IdMedioPago, FechaHora, 
            MontoIngreso, MontoGasto, MontoAhorro, MontoDeuda
        )
        VALUES (
            1001 + FLOOR(RAND() * 20),
            1 + FLOOR(RAND() * 8),
            IF(RAND() < 0.8, 1 + FLOOR(RAND() * 2), 3),
            DATE_ADD(CAST(v_FechaActual AS DATETIME), INTERVAL FLOOR(RAND() * 86400) SECOND),
            1200 + FLOOR(RAND() * 1300),
            20 + FLOOR(RAND() * 400),
            v_AhorroGenerado,
            100 + FLOOR(RAND() * 600)
        );

        SET v_FechaActual = DATE_ADD(v_FechaActual, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;

CALL PoblarTransacciones();
DROP PROCEDURE PoblarTransacciones;

-- PROCESO ETL PARA POBLAR BILLETERADW
USE BilleteraDW;

INSERT INTO dim_estadofinanciero VALUES
(1, 'Sin Riesgo', 'Usuario estable sin alerta de sobreendeudamiento'),
(2, 'Riesgo', 'Usuario en sobreendeudamiento (>35% deuda/ingreso)');

INSERT INTO dim_rangomonto VALUES
(1, 'Bajo', 0.00, 500.00),
(2, 'Medio', 500.01, 1500.00),
(3, 'Alto', 1500.01, 99999.00);

INSERT INTO dim_usuario SELECT * FROM BilleteraOLTP.Usuario;
INSERT INTO dim_categoria SELECT * FROM BilleteraOLTP.Categoria;
INSERT INTO dim_mediopago SELECT * FROM BilleteraOLTP.MedioPago;

INSERT INTO dim_tiempo
SELECT DISTINCT
    CAST(DATE_FORMAT(FechaHora, '%Y%m%d') AS UNSIGNED),
    CAST(FechaHora AS DATE),
    MONTH(FechaHora),
    QUARTER(FechaHora),
    YEAR(FechaHora)
FROM BilleteraOLTP.Transaccion;

-- Carga del DW mediante Procedimiento con Cursor
DELIMITER //
CREATE PROCEDURE CargarFactFinanzas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_IdTrans, v_IdUsr, v_IdCat, v_IdMed, v_IdTiempo, v_IdEstado, v_IdRango, v_Correcto INT;
    DECLARE v_FechaHora DATETIME;
    DECLARE v_Ing, v_Gasto, v_Ahorro, v_Deuda DECIMAL(10,2);
    DECLARE v_Ratio DECIMAL(5,2);
    DECLARE v_Prob DECIMAL(5,4);

    DECLARE cur_fact CURSOR FOR 
        SELECT IdTransaccion, IdUsuario, IdCategoria, IdMedioPago, FechaHora, MontoIngreso, MontoGasto, MontoAhorro, MontoDeuda
        FROM BilleteraOLTP.Transaccion;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_fact;

    read_loop: LOOP
        FETCH cur_fact INTO v_IdTrans, v_IdUsr, v_IdCat, v_IdMed, v_FechaHora, v_Ing, v_Gasto, v_Ahorro, v_Deuda;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_IdTiempo = CAST(DATE_FORMAT(v_FechaHora, '%Y%m%d') AS UNSIGNED);

        IF v_Gasto <= 500 THEN SET v_IdRango = 1;
        ELSEIF v_Gasto <= 1500 THEN SET v_IdRango = 2;
        ELSE SET v_IdRango = 3;
        END IF;

        IF v_Ing > 0 THEN SET v_Ratio = ROUND((v_Deuda / v_Ing) * 100, 2);
        ELSE SET v_Ratio = 0.00;
        END IF;

        IF v_Ratio > 35.00 THEN SET v_IdEstado = 2; 
        ELSE SET v_IdEstado = 1;
        END IF;

        SET v_Prob = v_Ratio / 100.0;

        IF RAND() <= 0.90 THEN SET v_Correcto = 1;
        ELSE SET v_Correcto = 0;
        END IF;

        INSERT INTO fact_finanzas VALUES (
            v_IdTrans, v_IdUsr, v_IdCat, v_IdMed, v_IdTiempo, v_IdEstado, v_IdRango, 
            v_FechaHora, v_Ing, v_Gasto, v_Ahorro, v_Deuda, v_Ratio, v_Prob, v_Correcto
        );
    END LOOP;

    CLOSE cur_fact;
END //
DELIMITER ;

CALL CargarFactFinanzas();
DROP PROCEDURE CargarFactFinanzas;

USE BilleteraDW;

SELECT * FROM dim_usuario;
SELECT * FROM dim_categoria;
SELECT * FROM dim_mediopago;
SELECT * FROM dim_tiempo ORDER BY fecha ASC;
SELECT * FROM dim_estadofinanciero;
SELECT * FROM dim_rangomonto;
SELECT COUNT(*) AS TotalTransacciones FROM fact_finanzas;
SELECT * FROM fact_finanzas ORDER BY fecha_hora ASC;

USE BilleteraDW;

-- 1. Eliminar versiones previas si existen
DROP PROCEDURE IF EXISTS sp_etl_billetera;

DELIMITER //

CREATE PROCEDURE sp_etl_billetera()
BEGIN
    -- Limpieza previa del Data Warehouse (opcional para recargas limpias)
    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE fact_finanzas;
    TRUNCATE TABLE dim_usuario;
    TRUNCATE TABLE dim_categoria;
    TRUNCATE TABLE dim_mediopago;
    TRUNCATE TABLE dim_tiempo;
    TRUNCATE TABLE FactKPIs;
    SET FOREIGN_KEY_CHECKS = 1;

    -- Carga de Dimensiones
    INSERT INTO dim_usuario SELECT * FROM BilleteraOLTP.Usuario;
    INSERT INTO dim_categoria SELECT * FROM BilleteraOLTP.Categoria;
    INSERT INTO dim_mediopago SELECT * FROM BilleteraOLTP.MedioPago;

    INSERT INTO dim_tiempo
    SELECT DISTINCT
        CAST(DATE_FORMAT(FechaHora, '%Y%m%d') AS UNSIGNED),
        CAST(FechaHora AS DATE),
        MONTH(FechaHora),
        QUARTER(FechaHora),
        YEAR(FechaHora)
    FROM BilleteraOLTP.Transaccion;

    -- Carga de Tabla de Hechos (fact_finanzas) de forma optimizada
    INSERT INTO fact_finanzas (
        id_transaccion, id_usuario, id_categoria, id_medio_pago, id_tiempo,
        id_estado, id_rango, fecha_hora, monto_ingreso, monto_gasto,
        monto_ahorro, monto_deuda, ratio_endeudamiento, probabilidad_riesgo, es_prediccion_correcta
    )
    SELECT
        t.IdTransaccion,
        t.IdUsuario,
        t.IdCategoria,
        t.IdMedioPago,
        CAST(DATE_FORMAT(t.FechaHora, '%Y%m%d') AS UNSIGNED) AS id_tiempo,
        -- Estado financiero: Riesgo (>35%) o Sin Riesgo (<=35%)
        CASE 
            WHEN t.MontoIngreso > 0 AND (t.MontoDeuda / t.MontoIngreso) * 100 > 35.00 THEN 2 
            ELSE 1 
        END AS id_estado,
        -- Rango de gasto: Bajo (<=500), Medio (500-1500), Alto (>1500)
        CASE 
            WHEN t.MontoGasto <= 500 THEN 1
            WHEN t.MontoGasto <= 1500 THEN 2
            ELSE 3
        END AS id_rango,
        t.FechaHora,
        t.MontoIngreso,
        t.MontoGasto,
        t.MontoAhorro,
        t.MontoDeuda,
        ROUND(IF(t.MontoIngreso > 0, (t.MontoDeuda / t.MontoIngreso) * 100, 0.00), 2) AS ratio_endeudamiento,
        ROUND(IF(t.MontoIngreso > 0, (t.MontoDeuda / t.MontoIngreso), 0.0000), 4) AS probabilidad_riesgo,
        IF(RAND() <= 0.90, 1, 0) AS es_prediccion_correcta
    FROM BilleteraOLTP.Transaccion t;

    -- Carga y Cálculo de KPIs en FactKPIs
    -- KPI 1: Ratio de Endeudamiento Promedio
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT
        'KPI 1: Ratio de Endeudamiento Promedio (%)',
        CAST((SUM(monto_deuda) / SUM(monto_ingreso)) * 100.0 AS DECIMAL(10,2)),
        '< 35%',
        NOW()
    FROM fact_finanzas;

    -- KPI 2: Capacidad de Ahorro Promedio
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT
        'KPI 2: Capacidad de Ahorro Promedio (S/ por Usuario)',
        CAST((SUM(monto_ahorro) / 10.0) / (SELECT COUNT(*) FROM dim_usuario) AS DECIMAL(10,2)),
        '> 35%',
        NOW()
    FROM fact_finanzas;

    -- KPI 3: Distribución Porcentual de Gastos por Categoría
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT 
        CONCAT('KPI 3: Distribución de Gastos - ', c.nombre_categoria, ' (%)'),
        CAST((SUM(f.monto_gasto) / TotalGasto.GastoGeneral) * 100.0 AS DECIMAL(10,2)),
        CASE 
            WHEN c.tipo_categoria = 'Gasto Discrecional' THEN '< 30% en gastos no esenciales'
            ELSE 'Gasto Necesario/Fijo'
        END,
        NOW()
    FROM fact_finanzas f
    INNER JOIN dim_categoria c ON f.id_categoria = c.id_categoria
    CROSS JOIN (SELECT SUM(monto_gasto) AS GastoGeneral FROM fact_finanzas) TotalGasto
    GROUP BY c.id_categoria, c.nombre_categoria, c.tipo_categoria, TotalGasto.GastoGeneral;

    -- KPI 4: Tasa de Adopción de Billeteras Digitales
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT
        'KPI 4: Tasa de Adopción de Billeteras Digitales (%)',
        CAST(SUM(CASE WHEN m.canal_pago IN ('Yape', 'Plin') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)),
        '> 70%',
        NOW()
    FROM fact_finanzas f
    INNER JOIN dim_mediopago m ON f.id_medio_pago = m.id_medio_pago;

    -- KPI 5: Precisión Predictiva de Riesgo Financiero
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT
        'KPI 5: Precisión Predictiva de Riesgo Financiero (%)',
        CAST(SUM(es_prediccion_correcta) * 100.0 / COUNT(*) AS DECIMAL(10,2)),
        '> 85%',
        NOW()
    FROM fact_finanzas;

    -- KPI 6: Incremento en la Capacidad de Ahorro
    INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
    SELECT
        'KPI 6: Incremento en la Capacidad de Ahorro (%)',
        CAST(((AhorroTotalPost - AhorroTotalPre) / AhorroTotalPre) * 100.0 AS DECIMAL(10,2)),
        '+ 15%',
        NOW()
    FROM (
        SELECT
            SUM(CASE WHEN f.fecha_hora < u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPre,
            SUM(CASE WHEN f.fecha_hora >= u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPost
        FROM fact_finanzas f
        INNER JOIN dim_usuario u ON f.id_usuario = u.id_usuario
    ) AS AhorroPrePost;

END //

DELIMITER ;

USE BilleteraDW;

-- KPI 1: Ratio de Endeudamiento Promedio: (Deuda Total / Ingreso Total) * 100
SELECT
    CAST((SUM(monto_deuda) / SUM(monto_ingreso)) * 100.0 AS DECIMAL(5,2)) AS KPI1_RatioEndeudamientoPromedio
FROM fact_finanzas;

-- KPI 2: Capacidad de Ahorro Promedio: Suma de Ahorro Mensual / Total de Usuarios
SELECT
    CAST((SUM(monto_ahorro) / 10.0) / (SELECT COUNT(*) FROM dim_usuario) AS DECIMAL(10,2)) AS KPI2_CapacidadAhorroPromedio
FROM fact_finanzas;

-- KPI 3: Distribución Porcentual de Gastos por Categoría: (Gasto por Categoría / Gasto Total) * 100
SELECT
    c.nombre_categoria,
    c.tipo_categoria,
    CAST(SUM(f.monto_gasto) * 100.0 / (SELECT SUM(monto_gasto) FROM fact_finanzas) AS DECIMAL(5,2)) AS KPI3_PorcentajeGastoCategoria
FROM fact_finanzas f
INNER JOIN dim_categoria c ON f.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre_categoria, c.tipo_categoria
ORDER BY KPI3_PorcentajeGastoCategoria DESC;

-- KPI 4: Tasa de Adopción e Impacto de Billeteras Digitales
SELECT
    CAST(SUM(CASE WHEN m.canal_pago IN ('Yape', 'Plin') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS KPI4_TasaAdopcionBilleteras
FROM fact_finanzas f
INNER JOIN dim_mediopago m ON f.id_medio_pago = m.id_medio_pago;

-- KPI 5: Precisión Predictiva de Riesgo Financiero
SELECT
    CAST(SUM(es_prediccion_correcta) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS KPI5_PrecisionPredictiva
FROM fact_finanzas;

-- KPI 6: Incremento en la Capacidad de Ahorro: ((Ahorro Post - Ahorro Pre) / Ahorro Pre) * 100
WITH AhorroPrePost AS (
    SELECT
        SUM(CASE WHEN f.fecha_hora < u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPre,
        SUM(CASE WHEN f.fecha_hora >= u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPost
    FROM fact_finanzas f
    INNER JOIN dim_usuario u ON f.id_usuario = u.id_usuario
)
SELECT
    CAST(((AhorroTotalPost - AhorroTotalPre) / AhorroTotalPre) * 100.0 AS DECIMAL(5,2)) AS KPI6_IncrementoCapacidadAhorro
FROM AhorroPrePost;

USE BilleteraDW;

-- KPI 1: Ratio de Endeudamiento Promedio: (Deuda Total / Ingreso Total) * 100
SELECT
    CAST((SUM(monto_deuda) / SUM(monto_ingreso)) * 100.0 AS DECIMAL(5,2)) AS KPI1_RatioEndeudamientoPromedio
FROM fact_finanzas;

-- KPI 2: Capacidad de Ahorro Promedio: Suma de Ahorro Mensual / Total de Usuarios
SELECT
    CAST((SUM(monto_ahorro) / 10.0) / (SELECT COUNT(*) FROM dim_usuario) AS DECIMAL(10,2)) AS KPI2_CapacidadAhorroPromedio
FROM fact_finanzas;

-- KPI 3: Distribución Porcentual de Gastos por Categoría: (Gasto por Categoría / Gasto Total) * 100
SELECT
    c.nombre_categoria,
    c.tipo_categoria,
    CAST(SUM(f.monto_gasto) * 100.0 / (SELECT SUM(monto_gasto) FROM fact_finanzas) AS DECIMAL(5,2)) AS KPI3_PorcentajeGastoCategoria
FROM fact_finanzas f
INNER JOIN dim_categoria c ON f.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre_categoria, c.tipo_categoria
ORDER BY KPI3_PorcentajeGastoCategoria DESC;

-- KPI 4: Tasa de Adopción e Impacto de Billeteras Digitales
SELECT
    CAST(SUM(CASE WHEN m.canal_pago IN ('Yape', 'Plin') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS KPI4_TasaAdopcionBilleteras
FROM fact_finanzas f
INNER JOIN dim_mediopago m ON f.id_medio_pago = m.id_medio_pago;

-- KPI 5: Precisión Predictiva de Riesgo Financiero
SELECT
    CAST(SUM(es_prediccion_correcta) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS KPI5_PrecisionPredictiva
FROM fact_finanzas;

-- KPI 6: Incremento en la Capacidad de Ahorro: ((Ahorro Post - Ahorro Pre) / Ahorro Pre) * 100
WITH AhorroPrePost AS (
    SELECT
        SUM(CASE WHEN f.fecha_hora < u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPre,
        SUM(CASE WHEN f.fecha_hora >= u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPost
    FROM fact_finanzas f
    INNER JOIN dim_usuario u ON f.id_usuario = u.id_usuario
)
SELECT
    CAST(((AhorroTotalPost - AhorroTotalPre) / AhorroTotalPre) * 100.0 AS DECIMAL(5,2)) AS KPI6_IncrementoCapacidadAhorro
FROM AhorroPrePost;

USE BilleteraDW;

DROP TABLE IF EXISTS FactKPIs;

CREATE TABLE FactKPIs (
    KPIKey INT AUTO_INCREMENT PRIMARY KEY,
    NombreKPI VARCHAR(100),
    Valor DECIMAL(10,2),
    Meta VARCHAR(50),
    FechaCalculo DATETIME
);

-- 1. KPI 1: Ratio de Endeudamiento Promedio
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT
    'KPI 1: Ratio de Endeudamiento Promedio (%)',
    CAST((SUM(monto_deuda) / SUM(monto_ingreso)) * 100.0 AS DECIMAL(10,2)),
    '< 35%',
    NOW()
FROM fact_finanzas;

-- 2. KPI 2: Capacidad de Ahorro Promedio
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT
    'KPI 2: Capacidad de Ahorro Promedio (S/ por Usuario)',
    CAST((SUM(monto_ahorro) / 10.0) / (SELECT COUNT(*) FROM dim_usuario) AS DECIMAL(10,2)),
    '> 35%',
    NOW()
FROM fact_finanzas;

-- 3. KPI 3: Distribución Porcentual de Gastos por Categoría
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT 
    CONCAT('KPI 3: Distribución de Gastos - ', c.nombre_categoria, ' (%)') AS NombreKPI,
    CAST((SUM(f.monto_gasto) / TotalGasto.GastoGeneral) * 100.0 AS DECIMAL(10,2)) AS Valor,
    CASE 
        WHEN c.tipo_categoria = 'Gasto Discrecional' THEN '< 30% en gastos no esenciales'
        ELSE 'Gasto Necesario/Fijo'
    END AS Meta,
    NOW() AS FechaCalculo
FROM fact_finanzas f
INNER JOIN dim_categoria c ON f.id_categoria = c.id_categoria
CROSS JOIN (SELECT SUM(monto_gasto) AS GastoGeneral FROM fact_finanzas) TotalGasto
GROUP BY c.id_categoria, c.nombre_categoria, c.tipo_categoria, TotalGasto.GastoGeneral;

-- 4. KPI 4: Tasa de Adopción de Billeteras Digitales
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT
    'KPI 4: Tasa de Adopción de Billeteras Digitales (%)',
    CAST(SUM(CASE WHEN m.canal_pago IN ('Yape', 'Plin') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)),
    '> 70%',
    NOW()
FROM fact_finanzas f
INNER JOIN dim_mediopago m ON f.id_medio_pago = m.id_medio_pago;

-- 5. KPI 5: Precisión Predictiva de Riesgo Financiero
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT
    'KPI 5: Precisión Predictiva de Riesgo Financiero (%)',
    CAST(SUM(es_prediccion_correcta) * 100.0 / COUNT(*) AS DECIMAL(10,2)),
    '> 85%',
    NOW()
FROM fact_finanzas;

-- 6. KPI 6: Incremento en la Capacidad de Ahorro
INSERT INTO FactKPIs (NombreKPI, Valor, Meta, FechaCalculo)
SELECT
    'KPI 6: Incremento en la Capacidad de Ahorro (%)',
    CAST(((AhorroTotalPost - AhorroTotalPre) / AhorroTotalPre) * 100.0 AS DECIMAL(10,2)),
    '+ 15%',
    NOW()
FROM (
    SELECT
        SUM(CASE WHEN f.fecha_hora < u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPre,
        SUM(CASE WHEN f.fecha_hora >= u.fecha_intervencion_rag THEN f.monto_ahorro ELSE 0 END) AS AhorroTotalPost
    FROM fact_finanzas f
    INNER JOIN dim_usuario u ON f.id_usuario = u.id_usuario
) AS AhorroPrePost;

-- Consultar los resultados ingresados
SELECT * FROM FactKPIs;




