import 'package:flutter/material.dart';
class IntroScreen extends StatelessWidget {
  
  final String title;
  final String subtitle;
  final String image;
  const IntroScreen({
    super.key,
    
    required this.title, required this.subtitle, required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Spacer(flex: 1),
        
        Container(
          height: 250,
          width: 250,
          decoration: BoxDecoration(
            //color: backgroundColor,
            image: DecorationImage(image: AssetImage("assets/images/onboarding/$image")),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        Spacer(flex: 2),
      ],
    );
  }
}
