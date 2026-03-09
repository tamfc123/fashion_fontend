import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSubmitted() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return current is AuthError || current is AuthAuthenticated;
        },
        listener: (context, state) {
          if (state is AuthError) {
            debugPrint('🔥 [LOGIN ERROR]: ${state.message}');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.fixed,
                ),
              );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AuthHeader(
                      title: 'Chào mừng trở lại!',
                      subtitle: 'Đăng nhập để vào cửa hàng',
                      imagePath: 'assets/images/login.png',
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                controller: _emailController,
                                label: 'Email',
                                readOnly: isLoading,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập Email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                controller: _passwordController,
                                label: 'Mật khẩu',
                                readOnly: isLoading,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập Mật khẩu';
                                  }
                                  if (value.length < 6) {
                                    return 'Mật khẩu tối thiểu 6 ký tự';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              AuthButton(
                                onPressed: _onLoginSubmitted,
                                text: 'Đăng Nhập',
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(
                        'Bạn chưa tham gia? Đăng ký ngay',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
