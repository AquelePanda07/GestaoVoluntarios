<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$id = (int) ($body['id'] ?? 0);
$nome = trim($body['nome'] ?? '');
$lotacao = trim($body['lotacao'] ?? '');
$tempo = trim($body['tempo'] ?? '');
$imagem = trim($body['imagem'] ?? '');

if ($id <= 0 || $nome === '' || $lotacao === '' || $tempo === '' || $imagem === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Dados inválidos para atualização.']);
    exit;
}

$lotacaoColumn = lotacao_column_sql($conn);
$stmt = $conn->prepare("UPDATE voluntarios SET nome = ?, $lotacaoColumn = ?, tempo = ?, imagem = ? WHERE id = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao preparar atualizacao: ' . $conn->error]);
    exit;
}

$stmt->bind_param('ssssi', $nome, $lotacao, $tempo, $imagem, $id);
$ok = $stmt->execute();
$stmt->close();

if (!$ok) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao atualizar voluntário.']);
    exit;
}

echo json_encode(['success' => true]);
