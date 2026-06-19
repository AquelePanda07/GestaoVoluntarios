<?php
require_once __DIR__ . '/db.php';

$lotacaoColumn = lotacao_column_sql($conn);
$sql = "SELECT id, nome, $lotacaoColumn AS lotacao, tempo, imagem FROM voluntarios ORDER BY id DESC";
$result = $conn->query($sql);

if (!$result) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Falha ao listar voluntarios: ' . $conn->error,
    ]);
    exit;
}

$voluntarios = [];
while ($row = $result->fetch_assoc()) {
    $voluntarios[] = $row;
}

echo json_encode([
    'success' => true,
    'voluntarios' => $voluntarios,
]);
