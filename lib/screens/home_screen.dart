import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'diagnosis_result_screen.dart';
import 'classification_detail_screen.dart';
import 'history_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/history_response.dart';
import '../models/history_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  int _selectedIndex = 0;
  late Timer _timer;

  // History related variables
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  HistoryResponse? _historyResponse;
  bool _isLoadingHistory = false;
  String? _historyError;

  List<Widget> get _banners {
    final List<Widget> banners = [];

    // Show history data if available
    if (_historyResponse != null && _historyResponse!.results.isNotEmpty) {
      // Add recent classifications as banners
      for (int i = 0; i < _historyResponse!.results.length && i < 3; i++) {
        final item = _historyResponse!.results[i];
        banners.add(_PlantBanner(historyItem: item));
      }
    } else {
      // Show welcome banner only if no history
      banners.add(
        _PremiumBanner(
          title: 'Start Your Journey 🌿',
          description:
              'Take your first plant photo to begin monitoring plant health',
        ),
      );
    }

    return banners;
  }

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

    // Load history on init
    _loadHistory();
  }

  @override
  void dispose() {
    _timer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final response = await _apiService.getHistory(page: 1, limit: 10);
      setState(() {
        _historyResponse = response;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _historyError = e.toString();
        _isLoadingHistory = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF16A34A); // Green
      case 'virus':
        return const Color(0xFFFF6B35); // Orange
      case 'fungi':
        return const Color(0xFF8B5CF6); // Purple
      case 'bacteria':
        return const Color(0xFFEF4444); // Red
      case 'pest':
        return const Color(0xFFF59E0B); // Amber
      case 'nematode':
        return const Color(0xFFDC2626); // Dark Red
      case 'pythopthora':
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  void _showImageSourceBottomSheet() {
    final navigatorContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),
            // Camera option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
              subtitle: const Text(
                'Use camera to take a new photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF7B7B7B),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (photo != null) {
                  Navigator.push(
                    navigatorContext,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiagnosisResultScreen(imagePath: photo.path),
                    ),
                  );
                }
              },
            ),
            // Gallery option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
              subtitle: const Text(
                'Select an existing photo from your device',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF7B7B7B),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (photo != null) {
                  Navigator.push(
                    navigatorContext,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiagnosisResultScreen(imagePath: photo.path),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onNavBarItemTapped(int index) {
    print('Navigation tapped: index = $index'); // Debug print

    if (index == 2) {
      // History tab - navigate to history screen
      print('Navigating to history screen...'); // Debug print
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building with selectedIndex: $_selectedIndex'); // Debug print
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          color: const Color(0xFF16A34A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF7B7B7B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Plant Health Assistant',
                            style: const TextStyle(
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
                          if (_historyResponse != null &&
                              _historyResponse!.results.isNotEmpty)
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
                                child: Text(
                                  _historyResponse!.results.length > 9
                                      ? '${_historyResponse!.results.length}+'
                                      : '${_historyResponse!.results.length}',
                                  style: const TextStyle(
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
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
                  ),
                  const SizedBox(height: 16),

                  // Recent Plant Diagnoses Section
                  const SizedBox(height: 20),
                  const Text(
                    'Recent Plant Diagnoses',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoadingHistory)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    )
                  else if (_historyError != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Error: $_historyError',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    )
                  else if (_historyResponse != null &&
                      _historyResponse!.results.isNotEmpty)
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.8,
                          ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _historyResponse!.results.length > 4
                          ? 4
                          : _historyResponse!.results.length,
                      itemBuilder: (context, index) {
                        final item = _historyResponse!.results[index];
                        return _PlantDiagnosisCard(
                          historyItem: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClassificationDetailScreen(
                                      classificationId: item.id,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: const Color(0xFF16A34A).withOpacity(0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Plant Diagnoses Yet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take your first plant photo to start monitoring plant health',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Color(0xFF7B7B7B),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
          onPressed: () {
            _showImageSourceBottomSheet();
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
              InkWell(
                onTap: () => _onNavBarItemTapped(0),
                borderRadius: BorderRadius.circular(8),
                child: _NavBarItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: _selectedIndex == 0,
                ),
              ),
              InkWell(
                onTap: () => _onNavBarItemTapped(1),
                borderRadius: BorderRadius.circular(8),
                child: _NavBarItem(
                  icon: Icons.search,
                  label: 'Diagnosis',
                  selected: _selectedIndex == 1,
                ),
              ),
              const SizedBox(width: 48), // space for FAB
              InkWell(
                onTap: () => _onNavBarItemTapped(2),
                borderRadius: BorderRadius.circular(8),
                child: _NavBarItem(
                  icon: Icons.history,
                  label: 'History',
                  selected: _selectedIndex == 2,
                ),
              ),
              InkWell(
                onTap: () => _onNavBarItemTapped(3),
                borderRadius: BorderRadius.circular(8),
                child: _NavBarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: _selectedIndex == 3,
                ),
              ),
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
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.image,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:
          onTap ??
          () {
            // Navigate to diagnosis screen or show diagnosis options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diagnosis feature coming soon!'),
                duration: Duration(seconds: 2),
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

class _PlantDiagnosisCard extends StatelessWidget {
  final HistoryItem historyItem;
  final VoidCallback? onTap;

  const _PlantDiagnosisCard({required this.historyItem, this.onTap, Key? key})
    : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF16A34A); // Green
      case 'virus':
        return const Color(0xFFFF6B35); // Orange
      case 'fungi':
        return const Color(0xFF8B5CF6); // Purple
      case 'bacteria':
        return const Color(0xFFEF4444); // Red
      case 'pest':
        return const Color(0xFFF59E0B); // Amber
      case 'nematode':
        return const Color(0xFFDC2626); // Dark Red
      case 'pythopthora':
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    historyItem.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF7B7B7B),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Plant Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(historyItem.predictedClass),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            historyItem.predictedClass,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${historyItem.confidencePercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plant Diagnosis',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to view details',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7B7B7B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _PlantBanner extends StatelessWidget {
  final HistoryItem historyItem;

  const _PlantBanner({required this.historyItem, Key? key}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF16A34A); // Green
      case 'virus':
        return const Color(0xFFFF6B35); // Orange
      case 'fungi':
        return const Color(0xFF8B5CF6); // Purple
      case 'bacteria':
        return const Color(0xFFEF4444); // Red
      case 'pest':
        return const Color(0xFFF59E0B); // Amber
      case 'nematode':
        return const Color(0xFFDC2626); // Dark Red
      case 'pythopthora':
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

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
              child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
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
                // Plant Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      historyItem.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF7B7B7B),
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Plant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                historyItem.predictedClass,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              historyItem.predictedClass,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${historyItem.confidencePercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recent Diagnosis',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your plant was diagnosed as ${historyItem.predictedClass.toLowerCase()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
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
                      horizontal: 16,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 36),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassificationDetailScreen(
                          classificationId: historyItem.id,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'VIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 12,
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
