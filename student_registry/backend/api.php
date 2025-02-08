<?php
// Add error logging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers,Content-Type,Access-Control-Allow-Methods');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$conn = new mysqli('localhost', 'root', '', 'student_registry');

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['check'])) {
            $studentNumber = $_GET['student_number'];
            $email = $_GET['email'];
            
            $sql = "SELECT COUNT(*) as count FROM students WHERE student_number = ? OR email = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ss", $studentNumber, $email);
            $stmt->execute();
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            
            echo json_encode(["exists" => $row['count'] > 0]);
            break;
        }
        
        $sql = "SELECT * FROM students";
        $result = $conn->query($sql);
        
        if (!$result) {
            http_response_code(500);
            echo json_encode(["error" => "Query failed: " . $conn->error]);
            break;
        }
        
        $students = array();
        while($row = $result->fetch_assoc()) {
            array_push($students, $row);
        }
        
        http_response_code(200);
        echo json_encode($students);
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        
        // Validate received data
        if (!$data) {
            http_response_code(400);
            echo json_encode(["error" => "Invalid JSON data received"]);
            break;
        }
        
        $sql = "INSERT INTO students (student_number, full_name, birthday, course, email, cp_number, password) 
                VALUES (?, ?, ?, ?, ?, ?, ?)";
                
        $stmt = $conn->prepare($sql);
        
        if (!$stmt) {
            http_response_code(500);
            echo json_encode(["error" => "Prepare failed: " . $conn->error]);
            break;
        }
        
        $stmt->bind_param("sssssss", 
            $data->student_number,
            $data->full_name,
            $data->birthday,
            $data->course,
            $data->email,
            $data->cp_number,
            $data->password
        );
        
        if($stmt->execute()) {
            http_response_code(200);
            echo json_encode(["message" => "Student registered successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error: " . $stmt->error]);
        }
        break;
}

$conn->close();