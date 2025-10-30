// ignore_for_file: use_build_context_synchronously
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> onboardingScreens = [
    {
      'title': 'Realice un seguimiento de sus gastos',
      'description':
          'Monitorea facilmente tus habitos de gasto e identifica areas donde puedes ahorrar dinero.',
      'image': 'lib/assets/onboarding-page-1.png',
    },
    {
      'title': 'Establece tu presupuesto',
      'description':
          'Planfique sus gastos e ingresos para mantenerse encaminado hacia sus objetios financieros.',
      'image': 'lib/assets/onboarding-page-2.png',
    },
    {
      'title': 'Alerta personalizada',
      'description':
          'Reciba alertas cuando estes cerca de tu limite presupestario o cuando haya transacciones inusuales, lo que te ayudara a manetenrte al tanto de tus finanzas.',
      'image': 'lib/assets/onboarding-page-3.png',
    },
  ];

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use one of your custom colors
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingScreens.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: onboardingScreens[index]['title']!,
                    description: onboardingScreens[index]['description']!,
                    image: onboardingScreens[index]['image']!,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary, // Use one of your custom colors
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _currentPage < onboardingScreens.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }
                          : () async {
                              // Navigate to the next screen or perform an action
                              GoRouter.of(context).go('/login');
                            }, // Disable button when on the last page

                      child: _currentPage < onboardingScreens.length - 1
                          ? const Text(
                              'Siguiente',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                               fontSize: 18),
                            )
                          : const Text(
                              'Empezar',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < onboardingScreens.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 400, height: 400),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground, // Use one of your custom colors
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onBackground, // Use one of your custom colors
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
