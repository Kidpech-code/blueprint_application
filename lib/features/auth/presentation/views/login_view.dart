import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../common/presentation/widgets/common_widgets.dart';
import '../../../../core/route_manager.dart';
import '../../../../core/dependency_injection.dart';
import '../../../../core/route_history.dart';
import '../../../../core/redirect_resolver.dart';

class LoginView extends StatefulWidget {
  final String? redirectTo;

  const LoginView({super.key, this.redirectTo});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 48, // Account for appbar and padding
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top spacer
                        const Spacer(flex: 1),

                        // Logo or App Title
                        Icon(Icons.lock_outline, size: 64, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 24),

                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Please sign in to your account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Error Message
                        if (authViewModel.error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(authViewModel.error!.message, style: TextStyle(color: Colors.red[700])),
                                ),
                                IconButton(icon: const Icon(Icons.close), onPressed: authViewModel.clearError, iconSize: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Login Button
                        AppButton(
                          text: 'Login',
                          onPressed: authViewModel.isLoading ? null : _login,
                          isLoading: authViewModel.isLoading,
                          icon: Icons.login,
                        ),
                        const SizedBox(height: 16),

                        // Register Link
                        TextButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () {
                                  AppRouter.goToRegister();
                                },
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Forgot Password Link
                        TextButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () {
                                  // Navigate to forgot password screen
                                  AppRouter.go('/forgot-password');
                                },
                          child: Text('Forgot Password?', style: TextStyle(color: Theme.of(context).primaryColor)),
                        ),

                        // Bottom spacer
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      authViewModel.login(_emailController.text.trim(), _passwordController.text).then((_) {
        if (authViewModel.isAuthenticated) {
          final redirect = resolveRedirect(
            widgetRedirect: widget.redirectTo,
            lastFromHistory: sl.isRegistered<RouteHistory>() ? sl<RouteHistory>().last : null,
            currentUserId: authViewModel.currentUser?.id,
          );

          AppRouter.go(redirect);
        }
      });
    }
  }
}
