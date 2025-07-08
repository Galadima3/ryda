import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ryda/main.dart';
import 'package:ryda/src/onboarding/onboarding_service.dart';
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
                title: 'Welcome to the Onboarding Screen',
                backgroundColor: Colors.blue,
              ),
              IntroScreen(
                title: 'Learn how to use the app',
                backgroundColor: Colors.green,
              ),
              IntroScreen(
                title: 'Get started now',
                backgroundColor: Colors.red,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Align(
              alignment: const Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                  onPressed: skipToLastPage,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  ),
                  SmoothPageIndicator(controller: controller, count: count),
                  MaterialButton(
                  onPressed: onLastPage
                    ? () async {
                      await LocalStorageService.setOnboardingSeen();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen(title: "Home");
                        },
                        ),
                      );
                      }
                    : nextPage,
                  color: Colors.transparent,
                  child: Text(
                    onLastPage ? 'Done' : 'Next',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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

class IntroScreen extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  const IntroScreen({
    super.key,
    required this.backgroundColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}
