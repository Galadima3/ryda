// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ryda/src/auth/service/firebase_auth_service.dart';
import 'package:ryda/src/auth/views/custom_snackbar_widget.dart';
import 'package:ryda/src/auth/views/custom_text_field.dart';

/// --- Providers ---
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');

final isFormValidProvider = Provider<bool>((ref) {
  final email = ref.watch(emailProvider).trim();
  final password = ref.watch(passwordProvider).trim();
  return email.isNotEmpty && password.isNotEmpty;
});

/// --- Register View ---
class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final authService = FirebaseAuthService(
        firebaseAuth: FirebaseAuth.instance,
      );
      await authService.register(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar.show(
        context,
        getFirebaseAuthErrorMessage(e),
        isError: true,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = ref.watch(isFormValidProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 226.h,
                  width: 300.w,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("assets/images/welcome.png"),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // Email Field
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  onChanged:
                      (val) => ref.read(emailProvider.notifier).state = val,
                ),

                // Password Field
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  validator: _validatePassword,
                  obscureText: true,
                  onChanged:
                      (val) => ref.read(passwordProvider.notifier).state = val,
                ),

                SizedBox(height: 17.5.h),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "By creating account, you agree to our company’s terms of service and privacy policy",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 15.h),
                SizedBox(
                  height: 40.h,
                  width: 241.w,
                  child: ElevatedButton.icon(
                    onPressed:
                        isFormValid
                            ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final email = ref.read(emailProvider);
                                final password = ref.read(passwordProvider);
                                register(email: email, password: password);
                              }
                            }
                            : null,
                    label:
                        isLoading
                            ? CircularProgressIndicator.adaptive(value: 5,backgroundColor: Colors.white,)
                            : const Text(
                              "Continue",
                              style: TextStyle(color: Colors.white),
                            ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 17.5.h),
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
