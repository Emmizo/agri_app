import 'package:flutter/material.dart';
import '../models/classification_result.dart';
import '../services/api_service.dart';

class ClassificationDetailScreen extends StatefulWidget {
  final String classificationId;
  
  const ClassificationDetailScreen({
    super.key,
    required this.classificationId,
  });

  @override
  State<ClassificationDetailScreen> createState() => _ClassificationDetailScreenState();
}

class _ClassificationDetailScreenState extends State<ClassificationDetailScreen> {
  final ApiService _apiService = ApiService();
  ClassificationResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassificationDetail();
  }

  Future<void> _loadClassificationDetail() async {
    try {
      final result = await _apiService.getClassificationDetail(widget.classificationId);
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
      appBar: AppBar(
        title: const Text(
          'Classification Detail',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF16A34A),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF7B7B7B),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF7B7B7B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClassificationDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_result == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF7B7B7B),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (_result!.imageUrl.isNotEmpty) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _result!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF0F0F0),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Color(0xFF7B7B7B),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Classification result card
          _DetailCard(
            title: 'Classification Result',
            children: [
              _DetailRow(
                label: 'Predicted Class',
                value: _result!.predictedClass,
                isHighlighted: true,
              ),
              _DetailRow(
                label: 'Confidence',
                value: '${_result!.confidencePercentage.toStringAsFixed(1)}%',
                isHighlighted: true,
              ),
              _DetailRow(
                label: 'Processing Time',
                value: '${_result!.processingTime.toStringAsFixed(2)}s',
              ),
              _DetailRow(
                label: 'Preprocessed',
                value: _result!.isPreprocessed ? 'Yes' : 'No',
              ),
              _DetailRow(
                label: 'Classification ID',
                value: _result!.id,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All predictions card
          _DetailCard(
            title: 'All Predictions',
            children: _result!.allPredictions.entries.map((entry) {
              return _DetailRow(
                label: entry.key,
                value: '${(entry.value * 100).toStringAsFixed(1)}%',
                isHighlighted: entry.key == _result!.predictedClass,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Recommendations card
          if (_result!.recommendations.isNotEmpty) ...[
            _DetailCard(
              title: 'Treatment Recommendations',
              children: [
                ..._result!.recommendations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final recommendation = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Color(0xFF222222),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Message card
          if (_result!.message.isNotEmpty) ...[
            _DetailCard(
              title: 'Message',
              children: [
                Text(
                  _result!.message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isHighlighted ? const Color(0xFF16A34A) : const Color(0xFF7B7B7B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
                color: isHighlighted ? const Color(0xFF16A34A) : const Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
