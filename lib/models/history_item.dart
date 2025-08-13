class HistoryItem {
  final String id;
  final String image;
  final String imageUrl;
  final String predictedClass;
  final double confidence;
  final double confidencePercentage;
  final Map<String, double> allPredictions;
  final List<String> recommendations;
  final bool isPreprocessed;
  final double processingTime;
  final String imageSize;
  final String createdAt;

  HistoryItem({
    required this.id,
    required this.image,
    required this.imageUrl,
    required this.predictedClass,
    required this.confidence,
    required this.confidencePercentage,
    required this.allPredictions,
    required this.recommendations,
    required this.isPreprocessed,
    required this.processingTime,
    required this.imageSize,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
      predictedClass: json['predicted_class'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercentage: (json['confidence_percentage'] ?? 0.0).toDouble(),
      allPredictions: Map<String, double>.from(json['all_predictions'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      isPreprocessed: json['is_preprocessed'] ?? false,
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
      imageSize: json['image_size'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'image_url': imageUrl,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'confidence_percentage': confidencePercentage,
      'all_predictions': allPredictions,
      'recommendations': recommendations,
      'is_preprocessed': isPreprocessed,
      'processing_time': processingTime,
      'image_size': imageSize,
      'created_at': createdAt,
    };
  }
}
