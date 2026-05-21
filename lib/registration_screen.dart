import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Helper for Deep Purple SnackBar
  void showStyledSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Data Store aur Auth ka function
  Future<void> registerUser() async {
    try {
      // Validation check
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          nameController.text.isEmpty) {
        showStyledSnackBar("Please fill all required fields!");
        return;
      }

      // Email Format Check (Regex)
      bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(emailController.text.trim());

      if (!emailValid) {
        showStyledSnackBar("Please enter a valid email address!");
        return;
      }

      // Loader dikhane ke liye
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );

      // STEP 1: Firebase Authentication mein account banana
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // STEP 2: Agar account ban jaye, to baqi data Firestore mein save karna
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'full_name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'cnic': cnicController.text.trim(),
              'dob': dobController.text.trim(),
              'age': ageController.text.trim(),
              'education': educationController.text.trim(),
              'created_at': DateTime.now(),
            });

        // Loader band karna
        Navigator.pop(context);

        showStyledSnackBar("Account Created Successfully! ✨");

        // STEP 3: Login screen par wapis bhej dena
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Loader band karna
      showStyledSnackBar(e.message ?? "Registration Failed");
    } catch (e) {
      Navigator.pop(context); // Loader band karna
      showStyledSnackBar("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/assets2.png", fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "JOIN US",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.deepPurple,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Create Profile",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          "Full Name",
                          Icons.person_outline,
                          nameController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "Email Address",
                          Icons.email_outlined,
                          emailController,
                          type: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "CNIC",
                          Icons.badge_outlined,
                          cnicController,
                          type: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "Date of Birth (DD/MM/YYYY)",
                          Icons.calendar_today_outlined,
                          dobController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "Age",
                          Icons.shutter_speed_outlined,
                          ageController,
                          type: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "Education",
                          Icons.school_outlined,
                          educationController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          "Password",
                          Icons.lock_outline,
                          passwordController,
                          isPass: true,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB39DDB),
                            minimumSize: const Size(double.infinity, 58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already a member? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPass = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: type,
      cursorColor: Colors.deepPurple,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3E5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
      ),
    );
  }
}
