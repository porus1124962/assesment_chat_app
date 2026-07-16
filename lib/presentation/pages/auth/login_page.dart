import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;

  const LoginPage({super.key, required this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool obscurePassword = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter email';
    if (!_isValidEmail(email)) return 'Please enter valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter password';
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
            } else if (state is AuthError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    Image.asset(
                      'images/codebase_logo.png',
                      height: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    TextFormField(
                      controller: emailController,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            defaultBorderRadius,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: passwordController,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            defaultBorderRadius,
                          ),
                        ),
                      ),
                      obscureText: obscurePassword,
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: widget.onRegisterTap,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
