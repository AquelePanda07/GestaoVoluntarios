<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$email = trim($body['email'] ?? '');
$senha = trim($body['senha'] ?? '');

if ($email === '' || $senha === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email e senha são obrigatórios.']);
    exit;
}

$stmt = $conn->prepare('SELECT nome, email, senha FROM usuarios WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();
$stmt->close();

if (!$user) {
    echo json_encode(['success' => false, 'reason' => 'not_found', 'message' => 'Usuário não encontrado.']);
    exit;
}

if ($user['senha'] !== $senha) {
    echo json_encode(['success' => false, 'reason' => 'invalid_password', 'message' => 'Senha incorreta.']);
    exit;
}

echo json_encode([
    'success' => true,
    'user' => [
        'nome' => $user['nome'],
        'email' => $user['email'],
    ],
]);
