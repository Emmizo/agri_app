import 'dart:io';
import 'package:flutter/material.dart';
import '../models/classification_result.dart';
import '../services/api_service.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final String imagePath;
  const DiagnosisResultScreen({Key? key, required this.imagePath})
    : super(key: key);

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  final ApiService _apiService = ApiService();
  ClassificationResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _classifyImage();
  }

  Future<void> _classifyImage() async {
    try {
      final file = File(widget.imagePath);
      final result = await _apiService.classifyImage(file);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                  child: _isLoading
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.green.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        )
                      : _error != null
                      ? Container(
                          height: 180,
                          color: Colors.red.shade100,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Error loading image',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.file(
                          File(widget.imagePath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                if (_isLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF16A34A)),
                        SizedBox(height: 16),
                        Text(
                          'Analyzing your plant...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _classifyImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_result != null) ...[
                  _DiagnosisSection(
                    number: 1,
                    title: 'Classification',
                    description:
                        'Predicted: ${_result!.predictedClass}\nConfidence: ${_result!.confidencePercentage.toStringAsFixed(1)}%\nProcessing Time: ${_result!.processingTime.toStringAsFixed(2)}s',
                  ),
                  const SizedBox(height: 16),
                  _DiagnosisSection(
                    number: 2,
                    title: 'All Predictions',
                    description: _result!.allPredictions.entries
                        .map(
                          (entry) =>
                              '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                        )
                        .join('\n'),
                  ),
                  const SizedBox(height: 16),
                  _DiagnosisSection(
                    number: 3,
                    title: 'Recommendations',
                    description: _result!.recommendations.join('\n'),
                    isRecommendation: true,
                  ),
                ],
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
