<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$id = (int) ($body['id'] ?? 0);

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID inválido.']);
    exit;
}

$stmt = $conn->prepare('DELETE FROM voluntarios WHERE id = ?');
$stmt->bind_param('i', $id);
$ok = $stmt->execute();
$stmt->close();

if (!$ok) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao excluir voluntário.']);
    exit;
}

echo json_encode(['success' => true]);
