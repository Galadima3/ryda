import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ryda/src/auth/service/firebase_auth_service.dart';
import 'package:ryda/src/auth/views/custom_snackbar_widget.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Function to show a SnackBar message.
    // Function to show a beautifully styled SnackBar message.
    // void showSnackBar(String message, {bool isError = false}) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Row(
    //         children: [
    //           Icon(
    //             isError ? Icons.error_outline : Icons.check_circle_outline,
    //             color: Colors.white,
    //             size: 24.sp,
    //           ),
    //           SizedBox(width: 10.w),
    //           Expanded(
    //             child: Text(
    //               message,
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 14.sp,
    //                 fontWeight: FontWeight.w500,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       backgroundColor: isError ? Colors.red[700] : Colors.green[700],
    //       duration: const Duration(seconds: 4),
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10.r),
    //       ),
    //       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    //       elevation: 6,
    //       // action: SnackBarAction(
    //       //   label: 'DISMISS',
    //       //   textColor: Colors.white,
    //       //   onPressed: () {
    //       //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //       //   },
    //       // ),
    //     ),
    //   );
    // }

    void loginWithDummy() async {
      try {
        await FirebaseAuthService(
          firebaseAuth: FirebaseAuth.instance,
        ).login(email: 'test@example.com', password: 'password123');
      } on FirebaseAuthException catch (e) {
        //showSnackBar(getFirebaseAuthErrorMessage(e), isError: true);
        CustomSnackBar.show(
          context,
          getFirebaseAuthErrorMessage(e),
          isError: true,
        );
      } catch (e) {
        CustomSnackBar.show(
          context,
          'An unexpected error occurred: $e',
          isError: true,
        );
      }
    }

    void dummyRegistration() async {
      try {
        await FirebaseAuthService(
          firebaseAuth: FirebaseAuth.instance,
        ).register(email: 'newuser@example.com', password: 'newpassword123');
      } on FirebaseAuthException catch (e) {
        CustomSnackBar.show(
          context,
          getFirebaseAuthErrorMessage(e),
          isError: true,
        );
      } catch (e) {
        CustomSnackBar.show(
          context,
          'An unexpected error occurred: $e',
          isError: true,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Ryda!',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30.h),
              // Dummy Email/Password Login Button
              ElevatedButton.icon(
                onPressed: () => loginWithDummy(),

                icon: const Icon(Icons.email),
                label: const Text('Login with Dummy Email'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  textStyle: TextStyle(fontSize: 16.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Dummy Registration Button
              ElevatedButton.icon(
                onPressed: () => dummyRegistration(),
                icon: const Icon(Icons.person_add),
                label: const Text('Register New Dummy User'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  textStyle: TextStyle(fontSize: 16.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Anonymous Sign-In Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInAnonymously();
                    //showSnackBar('Signed in anonymously!');
                  } on FirebaseAuthException catch (e) {
                    CustomSnackBar.show(
                      context,
                      getFirebaseAuthErrorMessage(e),
                      isError: true,
                    );
                  } catch (e) {
                    CustomSnackBar.show(
                      context,
                      'Error signing in anonymously: $e',
                      isError: true,
                    );
                  }
                },
                icon: const Icon(Icons.person_off),
                label: const Text('Sign In Anonymously'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  textStyle: TextStyle(fontSize: 16.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
