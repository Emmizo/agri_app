import 'dart:async';
import 'package:flutter/material.dart';
import 'diagnosis_result_screen.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  late Timer _timer;

  final List<Widget> _banners = [
    _PremiumBanner(
      title: 'Try Premium Features 🌵',
      description:
          'Claim your offer now and get unlimited recognition, health check and more',
    ),
    _PremiumBanner(
      title: 'New! Plant Identifier',
      description: 'Identify any plant instantly with our new AI-powered tool.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_banners.length > 1) {
        setState(() {
          _currentBanner = (_currentBanner + 1) % _banners.length;
          _bannerController.animateToPage(
            _currentBanner,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFE6F2EA),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF16A34A),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF7B7B7B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hilaire Shimwamana',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 28,
                          color: Color(0xFF7B7B7B),
                        ),
                        Positioned(
                          right: 0,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '9+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _bannerController,
                        onPageChanged: (index) {
                          setState(() => _currentBanner = index);
                        },
                        children: _banners,
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_banners.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentBanner == index
                                    ? const Color(0xFF16A34A)
                                    : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                  children: [
                    _FeatureCard(
                      title: 'Diagnose',
                      subtitle: "Check your plant's health",
                      image: 'assets/images/diagnose.png',
                    ),
                    _FeatureCard(
                      title: 'Identify',
                      subtitle: 'Recognize a plant',
                      image: 'assets/images/identify.png',
                    ),
                    _FeatureCard(
                      title: 'Water Calculator',
                      subtitle: 'Optimize watering for your plant',
                      image: 'assets/images/water.png',
                    ),
                    _FeatureCard(
                      title: 'Reminders',
                      subtitle: 'Stay on top of your plant care',
                      image: 'assets/images/reminder.png',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 8),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () async {
            final XFile? photo = await _picker.pickImage(
              source: ImageSource.camera,
            );
            if (photo != null) {
              // You can use photo.path here, e.g., show it in a new screen
              // For now, just pick and discard
            }
          },
          child: Icon(
            Icons.camera_alt,
            color: const Color(0xFF16A34A),
            size: 32,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(icon: Icons.home, label: 'Home', selected: true),
              _NavBarItem(icon: Icons.search, label: 'Diagnosis'),
              const SizedBox(width: 48), // space for FAB
              _NavBarItem(icon: Icons.people, label: 'Community'),
              _NavBarItem(icon: Icons.person, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.image,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisResultScreen(imagePath: image),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double imageWidth =
              constraints.maxWidth - 32; // account for padding
          final double imageHeight =
              constraints.maxHeight - 32; // account for padding
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Show only the top half of the image, anchored to the bottom
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ClipRect(
                    child: SizedBox(
                      width: imageWidth,
                      height: imageHeight / 2,
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                        width: imageWidth,
                        height: imageHeight,
                        alignment: Alignment.topLeft,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.local_florist,
                              size: 48,
                              color: Color(0xFF16A34A),
                            ),
                      ),
                    ),
                  ),
                ),
                // Title and subtitle at top left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Color(0xFF7B7B7B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavBarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFBDBDBD),
          size: 26,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
            color: selected ? const Color(0xFF16A34A) : const Color(0xFFBDBDBD),
          ),
        ),
      ],
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final String title;
  final String description;

  const _PremiumBanner({
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        children: [
          // Faint leafy background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.13,
              child: Image.asset(
                'assets/images/splash.png', // Use your leafy image asset here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Banner content
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF232323),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 36),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'GET IT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
