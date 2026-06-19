CREATE DATABASE IF NOT EXISTS voluntarios_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE voluntarios_db;

CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS voluntarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  `lotação` VARCHAR(255) NOT NULL,
  tempo VARCHAR(11) NOT NULL,
  imagem VARCHAR(255) NOT NULL
);

INSERT INTO usuarios (nome, email, senha)
SELECT 'Administrador', 'admin', 'admin'
WHERE NOT EXISTS (
  SELECT 1 FROM usuarios WHERE email = 'admin'
);
