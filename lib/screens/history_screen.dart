import 'package:flutter/material.dart';
import '../models/history_response.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';
import 'classification_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  HistoryResponse? _historyResponse;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiService.getHistory(page: page, limit: _limit);
      setState(() {
        if (page == 1) {
          _historyResponse = response;
        } else {
          // Append new results to existing ones
          _historyResponse = HistoryResponse(
            totalCount: response.totalCount,
            limit: response.limit,
            totalPages: response.totalPages,
            currentPage: response.currentPage,
            next: response.next,
            previous: response.previous,
            results: [
              ...(_historyResponse?.results ?? []),
              ...response.results,
            ],
          );
        }
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    await _loadHistory(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Classification History',
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
    if (_isLoading && _historyResponse == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16A34A)),
      );
    }

    if (_error != null && _historyResponse == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF7B7B7B)),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
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
              onPressed: _refreshHistory,
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

    if (_historyResponse?.results.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Color(0xFF7B7B7B)),
            const SizedBox(height: 16),
            Text(
              'No classification history',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your plant classifications will appear here',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF7B7B7B),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: (_historyResponse?.results.length ?? 0) + 1,
        itemBuilder: (context, index) {
          if (index == _historyResponse!.results.length) {
            // Show load more button if there are more pages
            if (_historyResponse!.next != null && !_isLoading) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _loadHistory(page: _currentPage + 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Load More',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            } else if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final item = _historyResponse!.results[index];
          return _HistoryCard(
            historyItem: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClassificationDetailScreen(classificationId: item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem historyItem;
  final VoidCallback? onTap;

  const _HistoryCard({required this.historyItem, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and basic info
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      historyItem.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF7B7B7B),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historyItem.predictedClass,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${historyItem.confidencePercentage.toStringAsFixed(1)}% confidence',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Processed in ${historyItem.processingTime.toStringAsFixed(2)}s',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF7B7B7B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Recommendations
            if (historyItem.recommendations.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommendations:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...historyItem.recommendations.take(3).map((
                      recommendation,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF7B7B7B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF7B7B7B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
