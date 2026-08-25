import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.brand, AppColors.brand2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: const Icon(Icons.movie_creation_rounded, size: 52, color: AppColors.brand),
              ),
              const SizedBox(height: 24),
              const Text(
                'ToonAI Studio',
                style: TextStyle(
                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI Cartoon Video Maker',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 32),
              const Text(
                'Apni Story, Apna Character, Apna Cartoon Video!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 26, height: 26,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
