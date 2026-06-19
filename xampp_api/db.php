<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = '127.0.0.1';
$user = 'root';
$pass = '';
$dbName = 'voluntarios_db';

mysqli_report(MYSQLI_REPORT_OFF);

$conn = new mysqli($host, $user, $pass, $dbName);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erro de conexão com MySQL: ' . $conn->connect_error,
    ]);
    exit;
}

$conn->set_charset('utf8mb4');

function read_json_body() {
    $raw = file_get_contents('php://input');
    $decoded = json_decode($raw, true);
    if (is_array($decoded)) {
        return $decoded;
    }
    return $_POST;
}

function get_lotacao_column(mysqli $conn): string {
    static $cached = null;

    if ($cached !== null) {
        return $cached;
    }

    $result = $conn->query('SHOW COLUMNS FROM voluntarios');
    if ($result) {
        $fallback = null;
        while ($row = $result->fetch_assoc()) {
            $field = $row['Field'] ?? '';
            $lower = strtolower($field);

            if ($lower === 'lotacao') {
                $cached = $field;
                return $cached;
            }

            if ($fallback === null && str_starts_with($lower, 'lota')) {
                $fallback = $field;
            }
        }

        if ($fallback !== null) {
            $cached = $fallback;
            return $cached;
        }
    }

    $cached = 'lotacao';
    return $cached;
}

function lotacao_column_sql(mysqli $conn): string {
    $column = get_lotacao_column($conn);
    return '`' . str_replace('`', '``', $column) . '`';
}
