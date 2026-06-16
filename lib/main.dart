/// main.dart
/// 
/// SMRS - Students Management Record System
/// A Flutter application that allows users to register student details
/// and fetch a list of registered students from a local PHP/MySQL backend.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// The base URL for the local PHP backend. 
/// Change this to your local machine's IP address (e.g., "http://192.168.1.x/...") 
/// if testing on a physical device instead of an emulator.
const String baseUrl = "http://localhost/";

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
/// Sets up the global theme and initial routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Utilizing a dark theme across the app for a modern look
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

/// The initial screen of the application containing the application bar 
/// and the student registration form.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "SMRS - Students Management Record System",
          style: GoogleFonts.bebasNeue(
            color: Colors.black,
            fontSize: 27.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      // SingleChildScrollView ensures the form is scrollable on smaller screens
      // or when the on-screen keyboard is visible.
      body: const SingleChildScrollView(
        child: RegistrationForm(),
      ),
    );
  }
}

/// A stateful widget that displays and manages the student registration form.
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  /// Global key to identify and validate the form state.
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input from the text fields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cgpaController = TextEditingController();

  /// Tracks the submission state to disable buttons and show loading indicators.
  bool isSubmitting = false;

  @override
  void dispose() {
    // Clean up controllers when the widget is removed from the widget tree
    // to prevent memory leaks.
    nameController.dispose();
    rollNoController.dispose();
    emailController.dispose();
    cgpaController.dispose();
    super.dispose();
  }

  /// Displays a brief non-blocking notification (SnackBar) at the bottom of the screen.
  /// 
  /// [msg] The text to display to the user.
  void _snack(String msg) {
    // Ensure the widget is still mounted before attempting to show a snackbar.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Validates the form and submits the data to the PHP backend via an HTTP POST request.
  Future<void> submitData() async {
    // Trigger validation on all FormFields using the form key.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return; // Halt submission if any validation fails.

    // Update state to show loading indicator.
    setState(() => isSubmitting = true);

    final url = Uri.parse("$baseUrl/insert_student.php");

    try {
      // Send a POST request with the form data.
      final response = await http.post(url, body: {
        "name": nameController.text.trim(),
        "roll_no": rollNoController.text.trim(),
        "email": emailController.text.trim(),
        "cgpa": cgpaController.text.trim(),
      });

      // Parse the JSON string response from the server into a Dart object.
      final decoded = jsonDecode(response.body);

      // The PHP API is expected to return a JSON object like: 
      // {"status":"success","message":"..."}
      if (decoded is Map && decoded["status"] == "success") {
        _snack(decoded["message"]?.toString() ?? "Inserted successfully.");

        // Clear the form fields upon successful insertion.
        nameController.clear();
        rollNoController.clear();
        emailController.clear();
        cgpaController.clear();
      } else if (decoded is Map) {
        // Handle server-side errors (e.g., duplicate roll numbers)
        _snack("Failed: ${decoded["message"] ?? "Unknown error"}");
      } else {
        // Handle unexpected server output (e.g., returning a boolean or array instead of an object)
        _snack("Unexpected server response (not a JSON object).");
      }
    } on FormatException catch (_) {
      // Thrown by jsonDecode if the server returns HTML or plain text instead of valid JSON.
      _snack("Insert API did not return valid JSON. Check your PHP output.");
    } catch (e) {
      // Catches network errors, CORS issues, or connection timeouts.
      _snack("Error connecting to server! Is XAMPP running?");
    } finally {
      // Always stop the loading indicator, regardless of success or failure.
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Register your details",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            
            // --- Name Field ---
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Enter name";
                return null;
              },
            ),
            const SizedBox(height: 15),

            // --- Roll Number Field ---
            TextFormField(
              controller: rollNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Roll Number",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = (v ?? "").trim();
                if (value.isEmpty) return "Enter roll number";
                // Ensure the input contains only valid integers
                if (int.tryParse(value) == null) return "Roll number must be a number";
                return null;
              },
            ),
            const SizedBox(height: 15),

            // --- Email Field ---
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "College Email",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = (v ?? "").trim();
                if (value.isEmpty) return "Enter email";
                // Basic email validation checking for the '@' symbol
                if (!value.contains("@")) return "Enter a valid email";
                return null;
              },
            ),
            const SizedBox(height: 15),

            // --- CGPA Field ---
            TextFormField(
              controller: cgpaController,
              // Allows decimal input on the soft keyboard
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "CGPA",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = (v ?? "").trim();
                if (value.isEmpty) return "Enter CGPA";
                final cgpa = double.tryParse(value);
                // Ensure input can be parsed into a decimal and falls within standard 0-10 bounds
                if (cgpa == null) return "CGPA must be a number";
                if (cgpa < 0 || cgpa > 10) return "CGPA must be between 0 and 10";
                return null;
              },
            ),
            const SizedBox(height: 15),

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disable button while submitting to prevent duplicate requests
                onPressed: isSubmitting ? null : submitData,
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("SUBMIT"),
              ),
            ),

            const SizedBox(height: 15),

            // --- Navigation Button to List Screen ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentListScreen()),
                  );
                },
                child: const Text("SHOW DETAILS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A screen that fetches and displays a list of registered students 
/// from the backend database.
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  /// Holds the list of students retrieved from the API.
  List<Map<String, dynamic>> students = [];
  
  /// Controls the visibility of the initial loading indicator.
  bool isLoading = true;
  
  /// Stores error messages if the data fetch fails, allowing the UI to display them.
  String? errorText;

  @override
  void initState() {
    super.initState();
    // Automatically trigger the data fetch when the screen is first loaded
    fetchData();
  }

  /// Displays a SnackBar for brief user feedback (e.g., when retrying a fetch).
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Retrieves the list of students via an HTTP GET request to the PHP backend.
  Future<void> fetchData() async {
    // Reset state before fetching
    setState(() {
      isLoading = true;
      errorText = null;
    });

    final url = Uri.parse("$baseUrl/fetch_students.php");

    try {
      final response = await http.get(url);

      // Check HTTP status code to ensure a successful request
      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorText = "Server error: ${response.statusCode}";
        });
        return;
      }

      final decoded = jsonDecode(response.body);

      // The fetch API is expected to return a JSON array of student objects:
      // [ {name:..., roll_no:..., email:..., CGPA:...}, ... ]
      if (decoded is List) {
        // Safely map the dynamic JSON list into a strongly typed Dart list
        final list = decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          students = list;
          isLoading = false;
        });
      } else if (decoded is Map) {
        // If the PHP script returns an error object (e.g., {"error": "..."}), display it safely
        setState(() {
          isLoading = false;
          errorText = "API error: ${decoded["message"] ?? decoded.toString()}";
        });
      } else {
        setState(() {
          isLoading = false;
          errorText = "Unexpected response (not a JSON array).";
        });
      }
    } on FormatException {
      // Commonly triggered if the PHP script encounters a fatal error and prints HTML/text,
      // or if it includes warnings before the JSON output.
      setState(() {
        isLoading = false;
        errorText = "Invalid JSON from server. Check PHP has no output before JSON.";
      });
    } catch (e) {
      // Catch network failures or timeout errors
      setState(() {
        isLoading = false;
        errorText = "Error fetching data: $e";
      });
    }
  }

  /// Helper function to extract the CGPA value safely, 
  /// accounting for potential case inconsistencies in the database column names.
  /// 
  /// [row] A single student data map.
  String _readCgpa(Map<String, dynamic> row) {
    final v = row["CGPA"] ?? row["cgpa"];
    return v?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Student Records"),
        backgroundColor: Colors.red,
        actions: [
          // Manual refresh button in the AppBar
          IconButton(
            onPressed: fetchData,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          // 1. Loading State
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          // 2. Error State
          : (errorText != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorText!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            _snack("Retrying...");
                            fetchData();
                          },
                          child: const Text("RETRY"),
                        ),
                      ],
                    ),
                  ),
                )
              // 3. Empty State
              : students.isEmpty
                  ? const Center(
                      child: Text(
                        "No records found in database.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  // 4. Data State (List view of students)
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          child: ListTile(
                            title: Text(
                              (s["name"] ?? "").toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Roll No: ${(s["roll_no"] ?? "").toString()}\n"
                              "Email: ${(s["email"] ?? "").toString()}\n"
                              "CGPA: ${_readCgpa(s)}",
                              style: const TextStyle(color: Colors.white70, height: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}