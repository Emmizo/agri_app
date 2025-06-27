import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final String imagePath;
  const DiagnosisResultScreen({Key? key, required this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF7B7B7B),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Diagnosis Result',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B7B7B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.green.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.local_florist,
                          size: 64,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DiagnosisSection(
                  number: 2,
                  title: 'Characteristics',
                  description:
                      'Large dark brown spots\n- Leaf edges turning black\n- White mold on underside in humid conditions',
                ),
                const SizedBox(height: 16),
                _DiagnosisSection(
                  number: 3,
                  title: 'Diseases',
                  description:
                      'Large dark brown spots\n- Leaf edges turning black\n- White mold on underside in humid conditions',
                ),
                const SizedBox(height: 16),
                _DiagnosisSection(
                  number: 1,
                  title: 'Recommendations',
                  description:
                      'Tips to keep your plant healthy\n- Remove infected leaves to stop the spread\n- Apply copper-based fungicide every 7 days\n- Avoid watering from above to keep leaves dry\n- Ensure good airflow between plants',
                  isRecommendation: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosisSection extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final bool isRecommendation;

  const _DiagnosisSection({
    required this.number,
    required this.title,
    required this.description,
    this.isRecommendation = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommendation
              ? const Color(0xFF16A34A)
              : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isRecommendation
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      color: isRecommendation
                          ? Colors.white
                          : const Color(0xFF16A34A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isRecommendation
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7B7B7B)),
          ),
        ],
      ),
    );
  }
}
