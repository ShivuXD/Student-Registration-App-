<?php
/**
 * insert_student.php
 * * SMRS - Students Management Record System
 * API Endpoint: Inserts a new student record into the database.
 * * This script receives POST data from the Flutter frontend, validates the
 * request method, establishes a secure database connection, and utilizes 
 * prepared statements to safely insert the student details into the MySQL database.
 */

// =========================================
// 1. CORS & Response Headers Configuration
// =========================================
// Ensure the response is properly formatted as JSON for the Dart frontend to decode
header('Content-Type: application/json; charset=UTF-8');
// Allow requests from any origin (required for Flutter web/mobile testing)
header("Access-Control-Allow-Origin: *");
// Explicitly allow POST methods and OPTIONS (for preflight requests)
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// =========================================
// 2. Database Connection Credentials
// =========================================
// Define the database connection parameters
$host = "localhost";
$username = "root";   // Default XAMPP MySQL username
$password = "";       // Default XAMPP MySQL password (empty)
$dbname = "Students"; // The target database name

// Establish a new MySQLi connection
$conn = new mysqli($host, $username, $password, $dbname);

// =========================================
// 3. Connection Error Handling
// =========================================
// Check if the connection was successful before proceeding
if ($conn->connect_error) {
    // Output a JSON encoded failure message if the database is unreachable
    http_response_code(500); // Set appropriate HTTP status for a server error
    die(json_encode([
        "status" => "failure", 
        "message" => "Connection failed: " . $conn->connect_error
    ]));
}

// =========================================
// 4. Request Method Validation
// =========================================
// Ensure that this endpoint is only accessed via an HTTP POST request.
// GET requests or direct browser accesses should be rejected immediately.
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // =========================================
    // 5. Data Retrieval & Sanitization
    // =========================================
    // Retrieve the POST data sent from the Flutter app.
    // Using the null coalescing operator (??) ensures that if a field is missing, 
    // it defaults to an empty string. This prevents PHP "Undefined index" warnings
    // which could corrupt the JSON output.
    $name    = $_POST['name'] ?? '';
    $roll_no = $_POST['roll_no'] ?? '';
    $email   = $_POST['email'] ?? '';
    $cgpa    = $_POST['cgpa'] ?? '';

    // =========================================
    // 6. Database Insertion (Prepared Statements)
    // =========================================
    // Prepare the SQL statement to insert the data.
    // Using parameter placeholders (?) instead of concatenating variables directly 
    // into the query is a critical security measure to prevent SQL Injection attacks.
    $stmt = $conn->prepare("INSERT INTO Information (name, roll_no, email, CGPA) VALUES (?, ?, ?, ?)");
    
    if ($stmt === false) {
        // Handle statement preparation failure (e.g., table doesn't exist, syntax error)
        http_response_code(500);
        die(json_encode([
            "status" => "failure", 
            "message" => "Failed to prepare statement: " . $conn->error
        ]));
    }

    // Bind the extracted variables to the prepared statement parameters.
    // The first argument ("sisd") specifies the exact data types expected:
    // 's' = string  (for name)
    // 'i' = integer (for roll_no)
    // 's' = string  (for email)
    // 'd' = double  (for cgpa - allows floating point numbers)
    $stmt->bind_param("sisd", $name, $roll_no, $email, $cgpa);

    // Execute the prepared query
    if ($stmt->execute()) {
        // If the row was inserted successfully, return a success status
        echo json_encode([
            "status" => "success", 
            "message" => "Student inserted successfully."
        ]);
    } else {
        // If execution fails (e.g., duplicate primary key for roll_no), return the specific error
        http_response_code(400); // 400 Bad Request / Data Conflict
        echo json_encode([
            "status" => "failure", 
            "message" => "Error inserting record: " . $stmt->error
        ]);
    }

    // Close the prepared statement to free up server resources
    $stmt->close();
    
} else {
    // =========================================
    // 7. Invalid Request Handling
    // =========================================
    // Respond with a structured error if accessed via GET, PUT, DELETE, etc.
    http_response_code(405); // 405 Method Not Allowed
    echo json_encode([
        "status" => "failure", 
        "message" => "Invalid request method. Expected POST."
    ]);
}

// Close the database connection once all operations are complete
$conn->close();
?>