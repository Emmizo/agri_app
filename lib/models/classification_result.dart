class ClassificationResult {
  final String id;
  final String predictedClass;
  final double confidence;
  final double confidencePercentage;
  final Map<String, double> allPredictions;
  final List<String> recommendations;
  final bool isPreprocessed;
  final double processingTime;
  final String imageUrl;
  final String message;

  ClassificationResult({
    required this.id,
    required this.predictedClass,
    required this.confidence,
    required this.confidencePercentage,
    required this.allPredictions,
    required this.recommendations,
    required this.isPreprocessed,
    required this.processingTime,
    required this.imageUrl,
    required this.message,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      id: json['id'] ?? '',
      predictedClass: json['predicted_class'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercentage: (json['confidence_percentage'] ?? 0.0).toDouble(),
      allPredictions: Map<String, double>.from(json['all_predictions'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      isPreprocessed: json['is_preprocessed'] ?? false,
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'confidence_percentage': confidencePercentage,
      'all_predictions': allPredictions,
      'recommendations': recommendations,
      'is_preprocessed': isPreprocessed,
      'processing_time': processingTime,
      'image_url': imageUrl,
      'message': message,
    };
  }
}
