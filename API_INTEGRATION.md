# API Integration Documentation

## Overview
This Flutter app integrates with the plant disease classification API at `https://hilaire01.pythonanywhere.com/api`.

## API Endpoints

### 1. Image Classification (`/api/classify/`)
- **Method**: POST
- **Purpose**: Upload and classify plant images for disease detection
- **Request**: Multipart form data with image file
- **Response**: Classification result with predictions and recommendations

#### Response Format:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "predicted_class": "Fungi",
  "confidence": 0.92,
  "confidence_percentage": 92,
  "all_predictions": {
    "Bacteria": 0.05,
    "Fungi": 0.92,
    "Nematode": 0.01,
    "Pest": 0.01,
    "Pythopthora": 0.01,
    "Virus": 0,
    "Healthy": 0
  },
  "recommendations": [
    "Apply fungicide treatments during favorable weather conditions",
    "Improve air circulation around plants by proper spacing",
    "Avoid overhead irrigation to reduce leaf wetness",
    "Practice crop rotation with non-susceptible crops",
    "Remove infected plant material and dispose properly"
  ],
  "is_preprocessed": false,
  "processing_time": 1.23,
  "image_url": "https://res.cloudinary.com/your-cloud/image/upload/v1234567890/potato_classifications/sample.jpg",
  "message": "Image classified successfully"
}
```

### 2. History (`/api/history/`)
- **Method**: GET
- **Purpose**: Retrieve classification history
- **Parameters**: 
  - `page` (integer): Page number for pagination
  - `limit` (integer): Number of results per page
- **Response**: Paginated list of classification results

### 3. Classification Detail (`/api/classification/{classification_id}/`)
- **Method**: GET
- **Purpose**: Retrieve detailed information about a specific classification
- **Parameters**: 
  - `classification_id` (string): The ID of the classification to retrieve
- **Response**: Detailed classification result with all information

## Implementation Details

### Dependencies
- `dio: ^5.4.0` - HTTP client for API calls

### Files Structure
```
lib/
├── services/
│   └── api_service.dart          # API service implementation
├── models/
│   ├── classification_result.dart # Classification result model
│   ├── history_item.dart         # History item model
│   └── history_response.dart     # History response model
└── screens/
    ├── diagnosis_result_screen.dart # Updated to use API
    ├── history_screen.dart       # History screen
    └── classification_detail_screen.dart # Classification detail screen
```

### Key Features

1. **Image Classification**
   - Camera integration for capturing plant images
   - Automatic API call when image is selected
   - Real-time loading states and error handling
   - Display of classification results with confidence scores

2. **History Management**
   - Paginated history view
   - Pull-to-refresh functionality
   - Load more functionality for pagination
   - Error handling and retry mechanisms

3. **Error Handling**
   - Network error handling
   - API error responses
   - User-friendly error messages
   - Retry functionality

### Usage Flow

1. **Image Classification**:
   - User taps camera button or diagnosis feature
   - Camera opens for image capture
   - Image is automatically sent to `/api/classify/`
   - Results are displayed with predictions and recommendations

2. **History View**:
   - User navigates to History tab in HomeScreen
   - App fetches history from `/api/history/`
   - Results are displayed in a scrollable list
   - Pagination allows loading more results
   - Tapping on a history item opens detailed view

3. **Classification Detail View**:
   - User taps on any history item
   - App fetches detailed information from `/api/classification/{id}/`
   - Shows comprehensive classification details
   - Displays image, predictions, and recommendations

### Error Scenarios Handled

- **Network Errors**: Connection timeouts, no internet
- **API Errors**: Invalid image format, file too large, server errors
- **Image Errors**: Corrupted images, unsupported formats
- **Empty States**: No history available

### Testing

To test the API integration:

1. Run the app: `flutter run`
2. Tap the camera button or any diagnosis feature
3. Take a photo of a plant
4. Wait for the classification result
5. Navigate to History tab to view past classifications

### Notes

- Maximum image size: 10MB
- Supported image formats: JPG, PNG, etc.
- API timeout: 30 seconds
- History pagination: 20 items per page by default
