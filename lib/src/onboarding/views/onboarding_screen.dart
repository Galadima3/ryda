import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ryda/src/auth/views/screens/register_view.dart';
import 'package:ryda/src/onboarding/views/intro_screen.dart';
import 'package:ryda/src/onboarding/service/onboarding_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  static const int count = 3;
  bool onLastPage = false;

  void nextPage() {
    final currentPage = controller.page?.round() ?? 0;
    if (currentPage < count - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void skipToLastPage() {
    controller.animateToPage(
      count - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                onLastPage = (value == count - 1);
              });
            },
            controller: controller,
            children: const [
              IntroScreen(
                title: 'Real-time tracking',
                subtitle:
                    "Be in every step of the way without actually being there",
                image: "1.png",
              ),
              IntroScreen(
                title: 'Book more than one Ryde!',
                subtitle: "Book multiple rydes at once",
                image: "2.png",
              ),
              IntroScreen(
                title: 'Tender easy appeal',
                subtitle:
                    "When stuck tender an easy appeal, we’re here to serve you",
                image: "3.png",
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: const Alignment(0, 0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: skipToLastPage,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: controller,
                    count: count,
                    effect: SlideEffect(
                      radius: 10,
                      dotWidth: 10.0,
                      dotHeight: 10.0,
                      spacing: 5
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        onLastPage
                            ? () async {
                              await LocalStorageService.setOnboardingSeen();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                     return RegisterView();
                                    },
                                  ),
                                );
                              }
                            }
                            : nextPage,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      minimumSize: WidgetStateProperty.all(Size(25.w, 29.h)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    //color: Colors.transparent,
                    child: Text(
                      onLastPage ? 'Done' : 'Next',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
