import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? error;
  bool showPassword = false;

  void _register() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      await _authService.registerWithEmail(
        emailController.text,
        passwordController.text,
      );
      Navigator.pop(context); // Kayıt sonrası giriş ekranına dön
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pastelPink = const Color(0xFFF8E1F4);
    final pastelBlue = const Color(0xFFE1F0FA);
    final pastelGreen = const Color(0xFFE1FAE6);
    final mainColor = const Color(0xFFB388FF);
    return Scaffold(
      backgroundColor: pastelPink,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pet-friendly illustration
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: pastelBlue,
                    child: Icon(Icons.pets, size: 56, color: mainColor),
                  ),
                ),
                Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: mainColor),
                          labelText: 'E-posta',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: mainColor),
                          labelText: 'Şifre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: mainColor,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style:
                              ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 2,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.disabled,
                                      )) {
                                        return pastelBlue;
                                      }
                                      return mainColor;
                                    }),
                              ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Zaten hesabın var mı?'),
                          TextButton(
                            onPressed: _goToLogin,
                            child: Text(
                              'Girişe Dön',
                              style: TextStyle(color: mainColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
