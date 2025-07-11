// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ryda/src/auth/service/firebase_auth_service.dart';
import 'package:ryda/src/auth/views/widgets/custom_snackbar_widget.dart';
import 'package:ryda/src/auth/views/widgets/custom_text_field.dart';
import 'package:ryda/src/auth/views/widgets/form_validators.dart';
import 'package:ryda/src/auth/views/screens/login_view.dart';

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

  Future<void> register({
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final authService = FirebaseAuthService(
        firebaseAuth: ref.watch(authInstanceProvider)
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
                  validator: FormValidators.validateEmail,
                  onChanged:
                      (val) => ref.read(emailProvider.notifier).state = val,
                ),

                // Password Field
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  validator: FormValidators.validatePassword,
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
                            ? CircularProgressIndicator(
                              value: 5,
                              backgroundColor: Colors.white,
                            )
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
                TextButton(
                  child: Text(
                    "Already have an account?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginView()),
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
