import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:print_ish_app/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';
import 'a_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUpMode = false;
  bool _isAdminMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _navigateToDashboard({bool isSubmittingLogin = false}) {
    final user = Supabase.instance.client.auth.currentUser;
    final isRealAdmin = user?.userMetadata?['role'] == 'admin' ||
        user?.appMetadata['role'] == 'admin';

    // Portal checks ONLY run when submitting a new login form
    if (isSubmittingLogin) {
      if (_isAdminMode && !isRealAdmin) {
        _showSnackBar(
          'Access Denied: Your account does not have admin privileges.',
          isError: true,
        );
        Supabase.instance.client.auth.signOut();
        return false;
      }

      if (!_isAdminMode && isRealAdmin) {
        _showSnackBar(
          'Admin accounts must sign in using the Admin Portal.',
          isError: true,
        );
        Supabase.instance.client.auth.signOut();
        return false;
      }

      // On successful login submission, reset stack directly to the target destination
      final destination = isRealAdmin ? const AdminDashboard() : const Dashboard();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
      return true;
    }

    // 1. If user is logged out (user == null) -> Reset to public Dashboard
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (route) => false,
      );
      return true;
    }

    // 2. If viewing profile/account page while logged in -> Simply pop back
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return true;
    }

    // 3. Otherwise navigate to appropriate dashboard
    final destination = isRealAdmin ? const AdminDashboard() : const Dashboard();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
    return true;
  }

  // --- Sign Out Method ---
  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      _showSnackBar('Logged out successfully.');
      _navigateToDashboard();
    } catch (e) {
      _showSnackBar('Error logging out: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Email & Password Sign In / Sign Up ---
  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Admin accounts cannot be self-signed up from the app
      if (_isSignUpMode && !_isAdminMode) {
        // Customer Sign Up
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (mounted && response.user != null) {
          _showSnackBar('Account created successfully!');
          _navigateToDashboard(isSubmittingLogin: true);
        }
      } else {
        // Sign In (Enforced for Admin Portal and Customer Sign In)
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // Verify if user profile exists in public.profiles (unless admin)
          try {
            final profile = await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('email', user.email!)
                .maybeSingle();

            if (profile == null && user.userMetadata?['role'] != 'admin') {
              await Supabase.instance.client.auth.signOut();
              _showSnackBar(
                'This account has been deleted by an administrator.',
                isError: true,
              );
              return;
            }
          } catch (_) {
            // Ignore if profiles table structure varies
          }
        }

        if (mounted) {
          final isAuthorized = _navigateToDashboard(isSubmittingLogin: true);
          if (isAuthorized) {
            _showSnackBar(
              _isAdminMode
                  ? 'Signed in as Admin successfully!'
                  : 'Welcome back! Signed in successfully.',
            );
          }
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Google Sign In ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // On Web: Use Supabase OAuth redirect flow with dynamic current origin
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
      } else {
        // On Mobile (Android / iOS): Use native GoogleSignIn prompt
        const webClientId =
            '818999666206-u1glik085prm7t2uq7en29airpt0kqo6.apps.googleusercontent.com';

        await GoogleSignIn.instance.initialize(
          serverClientId: webClientId,
        );

        final googleUser = await GoogleSignIn.instance.authenticate();

        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw 'No ID Token returned from Google.';
        }

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );

        if (mounted) {
          _showSnackBar('Signed in with Google successfully!');
          _navigateToDashboard();
        }
      }
    } catch (e) {
      _showSnackBar('Google Sign-In Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser != null
              ? 'Account'
              : (_isAdminMode ? 'Admin Portal' : 'Sign In'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToDashboard,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: currentUser != null
                ? _buildLoggedInView(theme, currentUser)
                : _buildAuthForm(theme),
          ),
        ),
      ),
    );
  }

  // --- View Shown When User Is Already Logged In ---
  Widget _buildLoggedInView(ThemeData theme, User user) {
    final isRealAdmin = user.userMetadata?['role'] == 'admin' ||
        user.appMetadata['role'] == 'admin';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          isRealAdmin
              ? Icons.admin_panel_settings_rounded
              : Icons.account_circle_rounded,
          size: 96,
          color: isRealAdmin ? Colors.deepOrange : theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          isRealAdmin ? 'Signed In As Admin' : 'Signed In As',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'Logged In User',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 36),
        ElevatedButton.icon(
          onPressed: _navigateToDashboard,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor:
                isRealAdmin ? Colors.deepOrange : theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          icon: Icon(isRealAdmin ? Icons.dashboard_rounded : Icons.storefront),
          label: Text(
            isRealAdmin ? 'Continue to Admin Dashboard' : 'Continue to Store',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _signOut,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Colors.red),
            foregroundColor: Colors.red,
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            'Log Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- View Shown When User Needs To Sign In / Sign Up ---
  Widget _buildAuthForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Branding Header / Admin Badge Header
          if (_isAdminMode)
            const Column(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 72,
                  color: AppColors.admin,
                ),
                SizedBox(height: 8),
              ],
            )
          else
            const Icon(
              Icons.print_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          const SizedBox(height: 12),
          Text(
            _isAdminMode ? 'Admin Portal' : 'Print-ish',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isAdminMode ? AppColors.admin : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isAdminMode
                ? 'Sign in with administrator credentials'
                : (_isSignUpMode
                    ? 'Create an account to get started'
                    : 'Welcome back! Sign in to continue'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 36),

          // Email Input Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _isAdminMode ? 'Admin Email' : 'Email Address',
              hintText: 'admin@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Input Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Button (Sign In / Sign Up)
          ElevatedButton(
            onPressed: _isLoading ? null : _submitEmailAuth,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor:
                  _isAdminMode ? Colors.deepOrange : theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isAdminMode
                        ? 'Sign In as Admin'
                        : (_isSignUpMode ? 'Create Account' : 'Sign In'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          if (!_isAdminMode) ...[
            // "OR" Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 24),

            // Google Sign-In Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: Image.asset(
                'lib/assets/images/google_logo.png',
                height: 30,
                width: 30,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_circle, size: 22),
              ),
              label: Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Toggle Sign In vs Sign Up Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUpMode
                      ? 'Already have an account? '
                      : "Don't have an account? ",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignUpMode = !_isSignUpMode;
                    });
                  },
                  child: Text(
                    _isSignUpMode ? 'Sign In' : 'Sign Up',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Admin Access / Portal Toggle Button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isAdminMode = !_isAdminMode;
                _isSignUpMode = false; // Always reset to Sign In mode for Admin Portal
              });
            },
            icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
            label: Text(
              _isAdminMode ? 'Switch to Customer Sign In' : 'Admin Portal Sign In',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor:
                  _isAdminMode ? Colors.deepPurple : Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}
