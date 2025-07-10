// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ryda/src/auth/service/firebase_auth_service.dart';
import 'package:ryda/src/auth/views/widgets/custom_snackbar_widget.dart';
import 'package:ryda/src/auth/views/widgets/custom_text_field.dart';
import 'package:ryda/src/auth/views/widgets/form_validators.dart';

/// --- Providers ---
final loginEmailProvider = StateProvider<String>((ref) => '');
final loginPasswordProvider = StateProvider<String>((ref) => '');

final isLoginFormValidProvider = Provider<bool>((ref) {
  final email = ref.watch(loginEmailProvider).trim();
  final password = ref.watch(loginPasswordProvider).trim();
  return email.isNotEmpty && password.isNotEmpty;
});

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();

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

  Future<void> login({required String email, required String password}) async {
    try {
      final authService = FirebaseAuthService(
        firebaseAuth: FirebaseAuth.instance,
      );
      await authService.login(email: email, password: password);
      // Navigate or show success
    } on FirebaseAuthException catch (e) {
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
    //final isFormValid = ref.watch(isLoginFormValidProvider);

    return Scaffold(
      appBar: AppBar(
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
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
              SizedBox(height: 20.h),

              CustomTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail,
                onChanged:
                    (val) => ref.read(loginEmailProvider.notifier).state = val,
              ),

              CustomTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                validator: FormValidators.validatePassword,
                onChanged:
                    (val) =>
                        ref.read(loginPasswordProvider.notifier).state = val,
              ),

              SizedBox(height: 20.h),
              SizedBox(
                height: 40.h,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(loginEmailProvider.notifier).state =
                        emailController.text;
                    ref.read(loginPasswordProvider.notifier).state =
                        passwordController.text;

                    if (_formKey.currentState?.validate() ?? false) {
                      final email = ref.read(loginEmailProvider);
                      final password = ref.read(loginPasswordProvider);
                      login(email: email, password: password);
                    }
                  },

                  label: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              
            ],
          ),
        ),
      ),
    );
  }
}
