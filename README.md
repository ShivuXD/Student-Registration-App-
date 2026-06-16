# SMRS - Students Management Record System 🎓

A simple, full-stack application for registering and managing student records. The frontend is built with **Flutter**, and the backend is powered by **PHP** and **MySQL**, designed to run on a local server environment like XAMPP.

## 🚀 Features

* **Student Registration:** A clean, validated form to input a student's name, roll number, college email, and CGPA.
* **View Records:** Fetch and display a real-time list of all registered students from the database.
* **State Management:** Graceful handling of loading states, network errors, and empty database states.
* **Secure Backend:** PHP backend utilizing prepared statements to prevent SQL injection.

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** PHP
* **Database:** MySQL
* **Dependencies:** `http` (for API requests), `google_fonts` (for typography)

---

## 🗄️ Database Setup (MySQL)

1. Open your XAMPP Control Panel and start **Apache** and **MySQL**.
2. Open your browser and go to `http://localhost/phpmyadmin/`.
3. Create a new database named **`Students`**.
4. Select the `Students` database, go to the **SQL** tab, and run the following query to create the required table:

```sql
CREATE TABLE Information (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    roll_no INT NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    CGPA DECIMAL(3,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);