<?php
/**
 * fetch_students.php
 * * SMRS - Students Management Record System
 * API Endpoint: Retrieves all student records from the database.
 * * This script connects to the local MySQL database, fetches the 
 * student information, and returns it as a JSON array for the Flutter frontend.
 */

// =========================================
// 1. CORS & Response Headers Configuration
// =========================================
// Allow requests from any origin (crucial for cross-platform Flutter development)
header("Access-Control-Allow-Origin: *");
// Allow specific HTTP methods required by the application
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
// Allow specific headers in the request
header("Access-Control-Allow-Headers: Content-Type");
// Ensure the response is correctly interpreted as JSON by the client
header("Content-Type: application/json; charset=UTF-8");

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
// Check if the connection was successful
if ($conn->connect_error) {
    // If connection fails, set a 500 HTTP status code and return a JSON error
    http_response_code(500);
    echo json_encode([
        "status" => "error", 
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit(); // Stop further execution immediately
}

// =========================================
// 4. Data Retrieval Logic
// =========================================
// Define the SQL query to fetch specific columns from the 'Information' table
$sql = "SELECT name, roll_no, email, CGPA FROM Information";

// Execute the query against the database
$result = $conn->query($sql);

// Initialize an empty array to hold the fetched student data
$students = array();

// =========================================
// 5. Data Processing & Output
// =========================================
// Safely check if the query executed properly and returned any rows
if ($result && $result->num_rows > 0) {
    // Iterate through each row in the result set
    // fetch_assoc() fetches a single result row as an associative array
    while ($row = $result->fetch_assoc()) {
        $students[] = $row; // Append the associative array (row) to our main array
    }
}

// Convert the populated PHP array into a JSON-formatted string and output it
// If the table is empty, this will gracefully output an empty JSON array: "[]"
echo json_encode($students);

// Close the database connection to free up server resources
$conn->close();
?>
?>