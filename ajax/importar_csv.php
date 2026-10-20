<?php
error_reporting(0);
header('Content-Type: application/json; charset=utf-8');
require_once '../config/conexion.php';

try {
    $pdo = Conexion::conectarOLTP();
    
    if (isset($_FILES['archivoCsv']['tmp_name']) && $_FILES['archivoCsv']['error'] == UPLOAD_ERR_OK) {
        $archivo = $_FILES['archivoCsv']['tmp_name'];
        $handle = fopen($archivo, "r");
        
        $primeraLinea = fgets($handle);
        $delimitador = (strpos($primeraLinea, ';') !== false) ? ';' : ',';
        rewind($handle);
        
        fgetcsv($handle, 1000, $delimitador); // Saltar cabeceras
        
        $insertados = 0;
        $usuariosProcesados = 0;

        while (($datos = fgetcsv($handle, 1000, $delimitador)) !== FALSE) {
            // Ahora exigimos que la fila tenga al menos 11 columnas
            if(count($datos) >= 11 && is_numeric($datos[0])) {
                
                // Mapeo de datos del Excel
                $idUsuario = $datos[0];
                $idCategoria = $datos[1];
                $idMedioPago = $datos[2];
                $fechaHora = $datos[3];
                $montoIngreso = $datos[4];
                $montoGasto = $datos[5];
                $montoAhorro = $datos[6];
                $montoDeuda = $datos[7];
                
                // Nuevos datos demográficos (Manejando celdas vacías)
                $edad = is_numeric($datos[8]) ? $datos[8] : NULL;
                $sexo = !empty($datos[9]) ? $datos[9] : 'No Especificado';
                $fechaRag = !empty($datos[10]) ? $datos[10] : NULL;
                
                // 1. ACTUALIZACIÓN / INSERCIÓN INTELIGENTE DE USUARIO
                $stmtUser = $pdo->prepare("
                    INSERT INTO Usuario (IdUsuario, Edad, Sexo, Rol, FechaIntervencionRAG) 
                    VALUES (?, ?, ?, 'Usuario', ?) 
                    ON DUPLICATE KEY UPDATE 
                    Edad = VALUES(Edad), 
                    Sexo = VALUES(Sexo), 
                    FechaIntervencionRAG = VALUES(FechaIntervencionRAG)
                ");
                $stmtUser->execute([$idUsuario, $edad, $sexo, $fechaRag]);
                $usuariosProcesados++;

                // 2. INSERCIÓN DE LA TRANSACCIÓN
                $stmtTrans = $pdo->prepare("INSERT INTO Transaccion (IdUsuario, IdCategoria, IdMedioPago, FechaHora, MontoIngreso, MontoGasto, MontoAhorro, MontoDeuda) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                $stmtTrans->execute([$idUsuario, $idCategoria, $idMedioPago, $fechaHora, $montoIngreso, $montoGasto, $montoAhorro, $montoDeuda]);
                
                $insertados++;
            }
        }
        fclose($handle);
        
        echo json_encode([
            'status' => 'success', 
            'message' => "Operación exitosa: Se registraron $insertados transacciones y se actualizaron los perfiles demográficos."
        ]);
        
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No se seleccionó ningún archivo o está corrupto.']);
    }
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error SQL: ' . $e->getMessage()]);
}
?>