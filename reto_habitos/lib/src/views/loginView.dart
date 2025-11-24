// lib/src/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 156, 175, 136),
                        Color.fromARGB(255, 184, 224, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 156, 175, 136).withOpacity(0.8),
                    const Color.fromARGB(255, 184, 224, 210).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // logo/icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(77, 255, 255, 255),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // title
                const Text(
                  'Reto de Hábitos',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(77, 0, 0, 0),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Completa tus retos a diario',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(77, 0, 0, 0),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // google sign in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color.fromARGB(255, 45, 52, 54),
                            elevation: 8,
                            shadowColor: const Color.fromARGB(77, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromARGB(255, 156, 175, 136),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        'lib/assets/images/googleIconNew.png',
                                        fit: BoxFit.contain,
                                        // errorBuilder: (context, error, stackTrace) {
                                        //   return const Icon(
                                        //     Icons.g_mobiledata,
                                        //     size: 24,
                                        //     color: Color.fromARGB(255, 45, 52, 54),
                                        //   );
                                        // },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: const Text(
                                        'Continuar con Google',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Text(
                      //   '',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.white.withOpacity(0.9),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      
      final GoogleSignInAccount? googleAuth = await googleSignIn.authenticate();
      
      if (googleAuth == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.authentication.idToken,
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text('Error al iniciar sesión: $e'),
            content: const Text('Error al iniciar sesión. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}