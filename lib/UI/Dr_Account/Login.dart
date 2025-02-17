import 'package:carecub/Logic/Users/ParentsLogic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Doctor_Booking/Doctor_Side/DoctorHome.dart';
import '../User/ForgotPassword.dart';
import 'Register/SignUp.dart';


class DrLogin extends StatefulWidget {
  const DrLogin({super.key});

  @override
  _DrLoginState createState() => _DrLoginState();
}

class _DrLoginState extends State<DrLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null && user.emailVerified) {
        // Check user role in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .get();


        if (userDoc.exists && userDoc['isVerified']==true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isDrLoggedIn', true);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard()),
                (Route<dynamic> route) => false,
          );
        } else {
          // Log the user out if they are not a doctor
          await FirebaseAuth.instance.signOut();
          showToast(message: 'You are not authorized to Login here');
        }
      } else {
        // Log the user out if email is not verified
        await FirebaseAuth.instance.signOut();
        showToast(message: 'Account not exists');

      }
    } catch (e) {
      showToast(message: 'Wrong Credentials');

    }
  }

  void _DrLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await signInUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          context: context,
        );
      } catch (e) {
        showToast(message: "Login Failed");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 25),
                  Column(
                    children: [
                      Text(
                        "Care Cub",
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            color: Colors.deepOrange),
                      ),
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                        AssetImage('assets/images/careCub_Logo.jpg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Welcome To Doctor's Portal",
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 25),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: false,
                                onChanged: (value) {},
                              ),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPassword()));
                              },
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(color: Colors.deepOrange),
                              )),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _DrLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 110),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()));
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
