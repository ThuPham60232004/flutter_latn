# Image Comparison Feature

This module implements the image comparison functionality with two main features:

## 🧩 Feature 1: Initial Image Upload

### Purpose
User taps a fixed image upload frame, selects an image from their device → the image is automatically uploaded with user_id to the backend via create-check-process API.

### API Endpoint
- **Method**: POST
- **URL**: `/api/create-check-process`
- **Content-Type**: multipart/form-data

### Request Fields
| Field | Type | Description |
|-------|------|-------------|
| user_id | string | The user identifier (e.g., "123") |
| image | binary (file) | The selected image from device |

### Response
```json
{
  "id": "68614bb65e3f196d274c5809",     // => process_id
  "userId": "123",
  "imageUrl": [
    "https://res.cloudinary.com/.../uploaded_image.webp"
  ]
}
```

### Stored Variables
- `process_id`: The ID returned from the backend
- `uploaded_image_url`: The image URL returned by the backend
- `user_id`: Pre-defined in the app or user session

## 🧩 Feature 2: Upload New Image & Compare via Slider

### Purpose
User selects another image to compare with the first one. The app sends the new image and user_id to the track-check-process/{process_id} API. The backend returns both images → displayed in a slider comparison UI.

### API Endpoint
- **Method**: POST
- **URL**: `/api/track-check-process/{process_id}`
- **Content-Type**: multipart/form-data

### Request Fields
| Field | Type | Description |
|-------|------|-------------|
| image | binary (file) | The new image to compare |
| user_id | string | The same user identifier |
| process_id | string | Sent in URL path, previously stored in app |

### Response
```json
{
  "first_image": "https://res.cloudinary.com/.../first_image.jpg",
  "latest_image": "https://res.cloudinary.com/.../latest_image.jpg"
}
```

### Stored Variables
- `first_image_url`: URL of the initial uploaded image
- `latest_image_url`: URL of the newly uploaded image
- `sliderValue`: Slider value (0.0 – 1.0) for comparison

## 📁 File Structure

```
lib/features/compare/
├── compare_screen.dart          # Main UI screen
├── models/
│   └── compare_model.dart       # Data models
├── services/
│   └── compare_service.dart     # API service
└── README.md                    # This documentation
```

## 🚀 Usage

1. **Navigation**: The compare screen is accessible via the bottom navigation bar (Compare tab)
2. **Initial Upload**: Tap the upload frame to select and upload the first image
3. **Comparison**: After initial upload, tap "Select Image to Compare" to upload a second image
4. **Slider Interaction**: Use the slider to compare the before/after images interactively

## ⚙️ Configuration

Update the API base URL in `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-actual-api-domain.com/api';
```

## 🔧 Dependencies

The following dependencies are required (already included in pubspec.yaml):
- `http`: For API calls
- `image_picker`: For image selection
- `shared_preferences`: For user ID storage

## 🎨 UI Features

- **Loading States**: Shows progress indicators during upload/comparison
- **Error Handling**: Displays user-friendly error messages
- **Success Feedback**: Green success messages for completed operations
- **Interactive Slider**: Smooth before/after image comparison
- **Responsive Design**: Adapts to different screen sizes
- **Visual Feedback**: Color-coded borders and status indicators

## 🔒 Security Notes

- User ID is stored in SharedPreferences
- Images are compressed to 80% quality before upload
- API endpoints use HTTPS
- Error messages don't expose sensitive information

## 🐛 Troubleshooting

1. **API Connection Issues**: Check the base URL in `api_config.dart`
2. **Image Upload Failures**: Verify image format and size
3. **Permission Issues**: Ensure camera/gallery permissions are granted
4. **Network Errors**: Check internet connectivity and API availability 