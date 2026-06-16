# Student-Registration-App
### Description
A basic student registration application built using Flutter, PHP, and MySQL. 
The application allows users to enter student details such as name, roll number, email address, and CGPA, store them in a MySQL database, and view the saved records through a simple user-friendly interface.

### Features
- Register student details
- Store data in a MySQL database
- Display saved student records
- Input validation for form fields
- Flutter Web frontend
- PHP backend with MySQL integration

### Tech Stack
- Flutter
- Dart
- PHP
- MySQL
- XAMPP

### Project Structure
· ```lib/``` – Flutter application source code

· ```insert_student.php ```– Handles insertion of student records into the database

· ```fetch_students.php``` – Retrieves records from the database

· ```pubspec.yaml``` – Flutter project dependencies

## How to Run?
1. Start Apache and MySQL in XAMPP
2. Create a MySQL database named Students
3. Import the required table structure
4. Place the PHP files inside the XAMPP htdocs directory

5. Run Flutter application:

```flutter pub get```

```flutter run -d chrome```
