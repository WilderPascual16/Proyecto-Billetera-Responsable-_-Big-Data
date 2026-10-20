<?php
require_once '../config/conexion.php';
header('Content-Type: application/json');

try {
    $pdo = Conexion::conectar();
    $stmt = $pdo->prepare("CALL sp_etl_billetera()");
    $stmt->execute();
    echo json_encode(['status' => 'success']);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error en ETL: ' . $e->getMessage()]);
}
?>