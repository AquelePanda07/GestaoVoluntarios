<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$nome = trim($body['nome'] ?? '');
$email = trim($body['email'] ?? '');
$senha = trim($body['senha'] ?? '');

if ($nome === '' || $email === '' || $senha === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Nome, email e senha são obrigatórios.']);
    exit;
}

$check = $conn->prepare('SELECT id FROM usuarios WHERE email = ? LIMIT 1');
$check->bind_param('s', $email);
$check->execute();
$exists = $check->get_result()->fetch_assoc();
$check->close();

if ($exists) {
    echo json_encode(['success' => false, 'reason' => 'already_exists', 'message' => 'Este e-mail já está cadastrado.']);
    exit;
}

$insert = $conn->prepare('INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)');
$insert->bind_param('sss', $nome, $email, $senha);
$ok = $insert->execute();
$insert->close();

if (!$ok) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao cadastrar usuário.']);
    exit;
}

echo json_encode(['success' => true, 'message' => 'Cadastro realizado com sucesso.']);
