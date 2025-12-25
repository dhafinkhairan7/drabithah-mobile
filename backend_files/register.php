<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
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

// Handle POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON data'
        ]);
        exit();
    }

    $username = $data['username'] ?? '';
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    $role = $data['role'] ?? 'user';
    $status = $data['status'] ?? 'Belum Verifikasi';

    // Validasi input
    if (empty($username) || empty($email) || empty($password)) {
        echo json_encode([
            'success' => false,
            'message' => 'Semua field harus diisi'
        ]);
        exit();
    }

    // Validasi email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            'success' => false,
            'message' => 'Email tidak valid'
        ]);
        exit();
    }

    // Check jika username sudah ada
    $check_username = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $check_username->bind_param("s", $username);
    $check_username->execute();
    $result_username = $check_username->get_result();

    if ($result_username->num_rows > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Username sudah digunakan'
        ]);
        exit();
    }

    // Check jika email sudah ada
    $check_email = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $check_email->bind_param("s", $email);
    $check_email->execute();
    $result_email = $check_email->get_result();

    if ($result_email->num_rows > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Email sudah digunakan'
        ]);
        exit();
    }

    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Insert user baru
    $stmt = $conn->prepare("INSERT INTO users (username, email, password, role, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())");
    $stmt->bind_param("sssss", $username, $email, $hashed_password, $role, $status);

    if ($stmt->execute()) {
        $user_id = $conn->insert_id;
        
        // Ambil data user yang baru dibuat
        $get_user = $conn->prepare("SELECT id, username, email, role, status, created_at FROM users WHERE id = ?");
        $get_user->bind_param("i", $user_id);
        $get_user->execute();
        $user_data = $get_user->get_result()->fetch_assoc();

        echo json_encode([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'user' => [
                'id' => $user_data['id'],
                'username' => $user_data['username'],
                'email' => $user_data['email'],
                'role' => $user_data['role'],
                'status' => $user_data['status'],
                'created_at' => $user_data['created_at']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Registrasi gagal: ' . $conn->error
        ]);
    }

    $stmt->close();
    $check_username->close();
    $check_email->close();
    $get_user->close();
}

$conn->close();
?>
