-- =============================================
-- Script: bdsteam.sql
-- Descripción: Creación de base de datos para gestión de tienda de videojuegos (Steam)
-- Entidades: 15 tablas con sus relaciones
-- =============================================

CREATE DATABASE IF NOT EXISTS bdsteam;
USE bdsteam;

-- 1. DESARROLLADOR
CREATE TABLE Desarrollador (
    desarrollador_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    sitio_web VARCHAR(255),
    pais VARCHAR(50),
    fecha_fundacion DATE
);

-- 2. USUARIO
CREATE TABLE Usuario (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    pais VARCHAR(50),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    saldo_cartera DECIMAL(10, 2) DEFAULT 0.00,
    estado_cuenta ENUM('Activo', 'Baneado', 'Inactivo') DEFAULT 'Activo'
);

-- 3. JUEGO
CREATE TABLE Juego (
    juego_id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_lanzamiento DATE,
    precio_actual DECIMAL(10, 2) NOT NULL,
    desarrollador_id INT,
    clasificacion_edad VARCHAR(10),
    CONSTRAINT fk_juego_desarrollador FOREIGN KEY (desarrollador_id) 
        REFERENCES Desarrollador(desarrollador_id) ON DELETE SET NULL
);

-- 4. ORDEN (Cabecera de compra)
CREATE TABLE Orden (
    orden_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NOT NULL,
    metodo_pago VARCHAR(50),
    CONSTRAINT fk_orden_usuario FOREIGN KEY (usuario_id) 
        REFERENCES Usuario(usuario_id)
);

-- 5. ORDEN_DETALLE (Items individuales por compra)
CREATE TABLE Orden_Detalle (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    juego_id INT NOT NULL,
    precio_pagado DECIMAL(10, 2) NOT NULL, -- Histórico del precio al momento de compra
    CONSTRAINT fk_detalle_orden FOREIGN KEY (orden_id) REFERENCES Orden(orden_id),
    CONSTRAINT fk_detalle_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 6. PRECIO_HISTORIAL (Para ofertas y sales)
CREATE TABLE Precio_Historial (
    historial_id INT AUTO_INCREMENT PRIMARY KEY,
    juego_id INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME,
    CONSTRAINT fk_historial_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 7. BIBLIOTECA (Relación Usuario-Juego tras la compra)
CREATE TABLE Biblioteca (
    usuario_id INT NOT NULL,
    juego_id INT NOT NULL,
    horas_jugadas DECIMAL(10, 1) DEFAULT 0.0,
    ultima_sesion DATETIME,
    fecha_adquisicion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, juego_id),
    CONSTRAINT fk_biblio_usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    CONSTRAINT fk_biblio_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 8. LOGRO (Achievements disponibles por juego)
CREATE TABLE Logro (
    logro_id INT AUTO_INCREMENT PRIMARY KEY,
    juego_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    rareza_porcentaje DECIMAL(5, 2),
    CONSTRAINT fk_logro_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 9. LOGRO_USUARIO (Progreso de logros)
CREATE TABLE Logro_Usuario (
    usuario_id INT NOT NULL,
    logro_id INT NOT NULL,
    fecha_desbloqueo DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, logro_id),
    CONSTRAINT fk_lu_usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    CONSTRAINT fk_lu_logro FOREIGN KEY (logro_id) REFERENCES Logro(logro_id)
);

-- 10. CATEGORIA
CREATE TABLE Categoria (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- 11. JUEGO_CATEGORIA (Relación N a N)
CREATE TABLE Juego_Categoria (
    juego_id INT NOT NULL,
    categoria_id INT NOT NULL,
    PRIMARY KEY (juego_id, categoria_id),
    CONSTRAINT fk_jc_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id),
    CONSTRAINT fk_jc_categoria FOREIGN KEY (categoria_id) REFERENCES Categoria(categoria_id)
);

-- 12. CAPTURA_PANTALLA (Media del juego)
CREATE TABLE Captura_Pantalla (
    captura_id INT AUTO_INCREMENT PRIMARY KEY,
    juego_id INT NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_captura_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 13. RESENA (Reviews)
CREATE TABLE Resena (
    resena_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    juego_id INT NOT NULL,
    comentario TEXT,
    recomendado BOOLEAN NOT NULL, -- True = Positiva, False = Negativa
    horas_al_momento DECIMAL(10, 1),
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_resena_usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    CONSTRAINT fk_resena_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- 14. AMIGO (Relación reflexiva)
CREATE TABLE Amigo (
    usuario_id_1 INT NOT NULL,
    usuario_id_2 INT NOT NULL,
    estado ENUM('Pendiente', 'Aceptado', 'Bloqueado') DEFAULT 'Pendiente',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id_1, usuario_id_2),
    CONSTRAINT fk_amigo1 FOREIGN KEY (usuario_id_1) REFERENCES Usuario(usuario_id),
    CONSTRAINT fk_amigo2 FOREIGN KEY (usuario_id_2) REFERENCES Usuario(usuario_id)
);

-- 15. LISTA_DESEOS (Wishlist)
CREATE TABLE Lista_Deseos (
    usuario_id INT NOT NULL,
    juego_id INT NOT NULL,
    fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, juego_id),
    CONSTRAINT fk_wish_usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    CONSTRAINT fk_wish_juego FOREIGN KEY (juego_id) REFERENCES Juego(juego_id)
);

-- =============================================
-- Índices sugeridos para optimización de búsquedas
-- =============================================
CREATE INDEX idx_juego_titulo ON Juego(titulo);
CREATE INDEX idx_precio_juego ON Precio_Historial(juego_id, fecha_inicio);
CREATE INDEX idx_orden_usuario ON Orden(usuario_id);
