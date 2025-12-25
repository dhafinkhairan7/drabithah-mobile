<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle POST request untuk logout
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Dalam implementasi nyata, Anda akan menghapus token dari database
    // atau melakukan session cleanup di sini
    
    echo json_encode([
        'success' => true,
        'message' => 'Logout berhasil'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
}
?>
