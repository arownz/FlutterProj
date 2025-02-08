<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers,Content-Type,Access-Control-Allow-Methods');

$conn = new mysqli('localhost', 'root', '', 'student_registry');

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        $sql = "SELECT * FROM students";
        $result = $conn->query($sql);
        $students = array();
        
        while($row = $result->fetch_assoc()) {
            array_push($students, $row);
        }
        
        echo json_encode($students);
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        
        $sql = "INSERT INTO students (student_number, full_name, birthday, course, email, cp_number) 
                VALUES (?, ?, ?, ?, ?, ?)";
                
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssss", 
            $data->student_number,
            $data->full_name,
            $data->birthday,
            $data->course,
            $data->email,
            $data->cp_number
        );
        
        if($stmt->execute()) {
            echo json_encode(array("message" => "Student registered successfully"));
        } else {
            echo json_encode(array("message" => "Error: " . $conn->error));
        }
        break;
}

$conn->close();
?>