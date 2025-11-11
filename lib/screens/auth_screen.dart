import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Captcha variables
  int _captchaAnswer = 0;
  int _captchaNum1 = 0;
  int _captchaNum2 = 0;
  bool _captchaIsAddition = true; // true for addition, false for subtraction
  bool _captchaVerified = false;
  final _captchaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Randomly choose addition or subtraction
    _captchaIsAddition = (random % 2) == 0;
    
    if (_captchaIsAddition) {
      // Addition: ensure numbers are different
      _captchaNum1 = (random % 10) + 1; // 1-10
      _captchaNum2 = ((random * 7) % 10) + 1; // 1-10
      
      // Make sure numbers are different
      while (_captchaNum2 == _captchaNum1) {
        _captchaNum2 = ((random * 11) % 10) + 1;
      }
      
      _captchaAnswer = _captchaNum1 + _captchaNum2;
    } else {
      // Subtraction: ensure result is positive
      _captchaNum1 = ((random % 10) + 5); // 5-14 (larger number)
      _captchaNum2 = ((random * 7) % 10) + 1; // 1-10 (smaller number)
      
      // Make sure num1 > num2 for positive result
      if (_captchaNum1 <= _captchaNum2) {
        _captchaNum1 = _captchaNum2 + ((random % 5) + 1);
      }
      
      _captchaAnswer = _captchaNum1 - _captchaNum2;
    }
    
    _captchaVerified = false;
    _captchaController.clear();
    if (mounted) {
      setState(() {});
    }
  }

  void _verifyCaptcha() {
    final userAnswer = int.tryParse(_captchaController.text.trim());
    if (userAnswer == _captchaAnswer) {
      setState(() {
        _captchaVerified = true;
      });
    } else {
      setState(() {
        _captchaVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect answer. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      _generateCaptcha();
    }
  }

  Widget _buildCaptcha() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _captchaVerified 
              ? Colors.green 
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: _captchaVerified ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _captchaVerified ? Icons.check_circle : Icons.security,
                color: _captchaVerified ? Colors.green : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Verification',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_captchaVerified) ...[
            Row(
              children: [
                Text(
                  _captchaIsAddition
                      ? 'What is $_captchaNum1 + $_captchaNum2?'
                      : 'What is $_captchaNum1 - $_captchaNum2?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _generateCaptcha,
                  tooltip: 'Generate new captcha',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _captchaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      hintText: 'Enter sum',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onFieldSubmitted: (_) => _verifyCaptcha(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _verifyCaptcha,
                  child: const Text('Verify'),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Verified',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _generateCaptcha,
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check captcha verification
    if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the security verification first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isSignUp) {
        await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim().isEmpty
              ? null
              : _displayNameController.text.trim(),
        );
      } else {
        await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (authProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
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

  // Commented out - Forgot password functionality disabled
  // Future<void> _handleForgotPassword() async {
  //   final email = _emailController.text.trim();
  //   
  //   // If email is not filled, show a dialog to enter it
  //   if (email.isEmpty) {
  //     final result = await showDialog<String>(
  //       context: context,
  //       builder: (context) => _ForgotPasswordDialog(),
  //     );
  //     
  //     if (result != null && result.isNotEmpty) {
  //       await _sendPasswordResetEmail(result);
  //     }
  //   } else {
  //     // Use the email from the field
  //     await _sendPasswordResetEmail(email);
  //   }
  // }

  // Future<void> _sendPasswordResetEmail(String email) async {
  //   // Validate email format
  //   if (!email.contains('@')) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please enter a valid email address'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     return;
  //   }

  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   
  //   // Show loading indicator
  //   if (!mounted) return;
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );

  //   try {
  //     await authProvider.resetPassword(email);

  //     if (mounted) {
  //       Navigator.of(context).pop(); // Close loading dialog
  //       
  //       if (authProvider.error != null) {
  //         // Show error message
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(authProvider.error!),
  //             backgroundColor: Colors.red,
  //             duration: const Duration(seconds: 5),
  //           ),
  //         );
  //       } else {
  //         // Success - Firebase sends email even if user doesn't exist (security)
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Password reset email sent to $email! Please check your inbox and spam folder.'),
  //             backgroundColor: Colors.green,
  //             duration: const Duration(seconds: 5),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       Navigator.of(context).pop(); // Close loading dialog
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Image.asset(
                      'logo.png',
                      height: 100,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: theme.colorScheme.primary,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Xibe Chat',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Create your account to sync across devices'
                          : 'Sign in to sync your chats',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Info message about settings and chat history
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your settings will be saved, but chat history will not be synced.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Display Name (only for sign up)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name (Optional)',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (_isSignUp && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password (only for sign in) - COMMENTED OUT
                    // if (!_isSignUp)
                    //   Align(
                    //     alignment: Alignment.centerRight,
                    //     child: TextButton(
                    //       onPressed: _handleForgotPassword,
                    //       child: const Text('Forgot Password?'),
                    //     ),
                    //   ),

                    const SizedBox(height: 16),

                    // Captcha
                    _buildCaptcha(),

                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isSignUp ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Sign Up/Sign In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(_isSignUp ? 'Sign In' : 'Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Commented out - Forgot password dialog disabled
// Dialog for entering email when forgot password is clicked without email
// class _ForgotPasswordDialog extends StatefulWidget {
//   @override
//   State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
// }

// class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
//   final _emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     
//     return AlertDialog(
//       title: const Text('Reset Password'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Enter your email address and we\'ll send you a link to reset your password.',
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 prefixIcon: Icon(Icons.email_outlined),
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//               autocorrect: false,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 if (!value.contains('@')) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//               autofocus: true,
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               Navigator.of(context).pop(_emailController.text.trim());
//             }
//           },
//           child: const Text('Send Reset Link'),
//         ),
//       ],
//     );
//   }
// }

