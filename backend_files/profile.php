<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Koneksi database untuk Laragon
$host = 'localhost';
$username = 'root'; // Username default Laragon
$password = ''; // Password default Laragon (kosong)
$database = 'drabithah_accounts';

$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $conn->connect_error
    ]);
    exit();
}

// Handle GET request untuk mendapatkan profil
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Untuk sekarang, kita ambil user dengan ID 1 sebagai contoh
    // Dalam implementasi nyata, Anda harus menggunakan token/session untuk identifikasi user
    $stmt = $conn->prepare("SELECT id, username, email, role, status, avatar, created_at, updated_at FROM users WHERE id = ?");
    $user_id = 1; // Ganti dengan ID user dari session/token
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        echo json_encode([
            'success' => false,
            'message' => 'User tidak ditemukan'
        ]);
        exit();
    }

    $user = $result->fetch_assoc();

    echo json_encode([
        'success' => true,
        'user' => [
            'id' => $user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'role' => $user['role'],
            'status' => $user['status'],
            'avatar' => $user['avatar'],
            'created_at' => $user['created_at'],
            'updated_at' => $user['updated_at']
        ]
    ]);

    $stmt->close();
}

$conn->close();
?>
