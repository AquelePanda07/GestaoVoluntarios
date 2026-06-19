<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$email = trim($body['email'] ?? '');

if ($email === '') {
    http_response_code(400);
    echo json_encode(['exists' => false, 'message' => 'Email é obrigatório.']);
    exit;
}

$stmt = $conn->prepare('SELECT id FROM usuarios WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();
$exists = (bool) $result->fetch_assoc();
$stmt->close();

echo json_encode(['exists' => $exists]);
