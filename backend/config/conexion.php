<?php
class Conexion {
    public static function conectar() {
        try {
            $pdo = new PDO("mysql:host=127.0.0.1;dbname=BilleteraDW;charset=utf8", "root", "");
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $pdo;
        } catch (\PDOException $e) { 
            die(json_encode(['status' => 'error', 'message' => 'Error DW: ' . $e->getMessage()])); 
        }
    }
    public static function conectarOLTP() {
        try {
            $pdo = new PDO("mysql:host=127.0.0.1;dbname=BilleteraOLTP;charset=utf8", "root", "");
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $pdo;
        } catch (\PDOException $e) { 
            die(json_encode(['status' => 'error', 'message' => 'Error OLTP: ' . $e->getMessage()])); 
        }
    }
}
?>