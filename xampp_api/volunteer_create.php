<?php
require_once __DIR__ . '/db.php';

$body = read_json_body();
$nome = trim($body['nome'] ?? '');
$lotacao = trim($body['lotacao'] ?? '');
$tempo = trim($body['tempo'] ?? '');
$imagem = trim($body['imagem'] ?? '');

if ($nome === '' || $lotacao === '' || $tempo === '' || $imagem === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Todos os campos são obrigatórios.']);
    exit;
}

$lotacaoColumn = lotacao_column_sql($conn);
$stmt = $conn->prepare("INSERT INTO voluntarios (nome, $lotacaoColumn, tempo, imagem) VALUES (?, ?, ?, ?)");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao preparar criacao: ' . $conn->error]);
    exit;
}

$stmt->bind_param('ssss', $nome, $lotacao, $tempo, $imagem);
$ok = $stmt->execute();
$stmt->close();

if (!$ok) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Falha ao criar voluntário.']);
    exit;
}

echo json_encode(['success' => true]);
