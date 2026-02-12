
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _showPass = false;
  String? _errorMessage;

  Future<void> _login(String email, String password) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final userData = await userDoc.get();

        if (!userData.exists) {
          await userDoc.set({
            "email": user.email,
            "role": "admin" // غيرها إذا بدك user
          });
        }

        final role = (await userDoc.get())['role'];

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          setState(() {
            _errorMessage = "هذا المستخدم ليس له صلاحية الدخول";
          });
        }
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'لم يتم العثور على هذا المستخدم';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'كلمة المرور غير صحيحة';
        } else {
          _errorMessage = 'حدث خطأ أثناء تسجيل الدخول: ${e.message}';
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _errorMessage = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF80DEEA),
                Color(0xFFFFECB3)
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 340,
              height: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                    )]
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          cursorColor: Colors.indigo.withOpacity(1),
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.3),
                            filled: true,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person,color: Colors.indigo.withOpacity(1),),
                            labelText: "اسم المستخدم",
                            labelStyle: TextStyle(color: Colors.indigo.withOpacity(1)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المستخدم';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPass,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.3),
                            filled: true,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock,color: Colors.indigo.withOpacity(1),),
                            labelText: "كلمة المرور",
                            labelStyle: TextStyle(color: Colors.indigo.withOpacity(1)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPass ? Icons.visibility : Icons.visibility_off,
                                color: Colors.indigo.withOpacity(1),
                              ),

                              onPressed: () {
                                setState(() {
                                  _showPass = !_showPass;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 50),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  _loading
                      ? const CircularProgressIndicator()
                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF80DEEA),
                          Color(0xFFFFECB3)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ElevatedButton(

                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          await _login(
                            _usernameController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          )
                      ),

                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(fontSize: 18,color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




