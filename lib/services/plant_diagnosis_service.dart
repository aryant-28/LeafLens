import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditionally import tflite_flutter
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/diagnosis_result.dart';

// Import tflite_flutter only on mobile platforms
// We use this approach to avoid import errors on web
// ignore: uri_does_not_exist
import 'package:tflite_flutter/tflite_flutter.dart'
    if (kIsWeb) 'package:flutter/material.dart' as tfl;

class PlantDiagnosisService {
  // Model names - you would replace these with your actual model files
  static const String _resnetModel =
      'assets/ml_models/resnet50_plant_disease.tflite';
  static const String _efficientNetModel =
      'assets/ml_models/efficientnet_b0_plant_disease.tflite';

  // Class labels - these would be loaded from a file in a real app
  static final List<String> _diseaseLabels = [
    'Healthy',
    'Apple Black Rot',
    'Apple Scab',
    'Apple Cedar Rust',
    'Cherry Powdery Mildew',
    'Corn Gray Leaf Spot',
    'Corn Common Rust',
    'Corn Northern Leaf Blight',
    'Grape Black Rot',
    'Grape Esca (Black Measles)',
    'Grape Leaf Blight',
    'Peach Bacterial Spot',
    'Pepper Bacterial Spot',
    'Potato Early Blight',
    'Potato Late Blight',
    'Squash Powdery Mildew',
    'Strawberry Leaf Scorch',
    'Tomato Bacterial Spot',
    'Tomato Early Blight',
    'Tomato Late Blight',
    'Tomato Leaf Mold',
    'Tomato Septoria Leaf Spot',
    'Tomato Spider Mites',
    'Tomato Target Spot',
    'Tomato Yellow Leaf Curl Virus',
    'Tomato Mosaic Virus',
  ];

  // Disease information database - this would come from an API in a real app
  static final Map<String, Map<String, dynamic>> _diseaseInfo = {
    'Healthy': {
      'description':
          'Your plant appears to be healthy! No signs of disease or stress detected.',
      'remedies': [
        'Continue with regular care and maintenance.',
        'Ensure proper watering, fertilization, and sunlight.'
      ],
      'prevention_tips': [
        'Regular monitoring for early signs of stress or disease.',
        'Maintain good air circulation around plants.',
        'Avoid overwatering or overcrowding plants.'
      ],
      'condition': 'healthy',
    },
    'Apple Black Rot': {
      'description':
          'Black rot is a fungal disease that affects apple trees, causing leaf spots and fruit rot.',
      'remedies': [
        'Remove and destroy infected fruits and leaves.',
        'Apply fungicides containing captan or myclobutanil as recommended.',
        'Prune affected branches during the dormant season.'
      ],
      'prevention_tips': [
        'Maintain proper tree spacing for good air circulation.',
        'Clean up fallen leaves and fruit from the orchard floor.',
        'Apply preventative fungicide sprays during the growing season.'
      ],
      'condition': 'moderate',
    },
    'Tomato Late Blight': {
      'description':
          'Late blight is a serious fungal disease that affects tomatoes, causing dark lesions on leaves and fruits.',
      'remedies': [
        'Remove and destroy all infected plant parts immediately.',
        'Apply copper-based fungicides at the first sign of infection.',
        'Increase plant spacing to improve air circulation.'
      ],
      'prevention_tips': [
        'Use resistant tomato varieties when available.',
        'Avoid overhead watering that wets the foliage.',
        'Rotate tomato crops every 2-3 years.'
      ],
      'condition': 'severe',
    },
    // Add more diseases as needed
  };

  // This method works on all platforms
  Future<DiagnosisResult> diagnoseImage(dynamic imageSource) async {
    // For web or if TensorFlow model is not available, use mock implementation
    if (kIsWeb) {
      return _getMockDiagnosis();
    }

    // For mobile platforms with proper File object
    try {
      // Simulate model processing time
      await Future.delayed(const Duration(seconds: 2));

      // Get a random disease for demonstration
      final random = math.Random();
      final isHealthy =
          random.nextDouble() > 0.8; // 20% chance of being healthy

      String diseaseName;
      if (isHealthy) {
        diseaseName = 'Healthy';
      } else {
        // Select a random disease from our labels (excluding the healthy one)
        final diseaseIndex =
            random.nextInt(_diseaseLabels.length - 1) + 1; // Skip healthy
        diseaseName = _diseaseLabels[diseaseIndex];
      }

      // If we don't have info for this disease, default to a common one
      final diseaseData =
          _diseaseInfo[diseaseName] ?? _diseaseInfo['Tomato Late Blight']!;

      // Generate a confidence score - higher for healthy, more variable for diseases
      final confidence = isHealthy
          ? 0.85 + (random.nextDouble() * 0.15) // 85-100% for healthy
          : 0.6 + (random.nextDouble() * 0.3); // 60-90% for diseases

      // Convert string condition to enum
      final condition = _stringToCondition(diseaseData['condition']);

      return DiagnosisResult(
        diseaseName: diseaseName,
        description: diseaseData['description'],
        remedies: List<String>.from(diseaseData['remedies']),
        preventionTips: List<String>.from(diseaseData['prevention_tips']),
        confidence: confidence,
        condition: condition,
      );
    } catch (e) {
      throw Exception('Failed to diagnose leaf image: $e');
    }
  }

  // Backward compatibility method for non-web platforms
  Future<DiagnosisResult> diagnoseLeaf(File imageFile) async {
    return diagnoseImage(imageFile);
  }

  // Special mock implementation for web platform
  Future<DiagnosisResult> _getMockDiagnosis() async {
    // Simulate model processing time
    await Future.delayed(const Duration(seconds: 2));

    // Get a random disease for demonstration (for web)
    final random = math.Random();
    final diseaseIndex = random.nextInt(_diseaseLabels.length);
    final diseaseName = _diseaseLabels[diseaseIndex];

    // If we don't have info for this disease, default to a common one
    final diseaseData =
        _diseaseInfo[diseaseName] ?? _diseaseInfo['Tomato Late Blight']!;

    return DiagnosisResult(
      diseaseName: diseaseName,
      description: diseaseData['description'],
      remedies: List<String>.from(diseaseData['remedies']),
      preventionTips: List<String>.from(diseaseData['prevention_tips']),
      confidence: 0.7 + (random.nextDouble() * 0.2), // 70-90% confidence
      condition: _stringToCondition(diseaseData['condition']),
    );
  }

  // Helper method to convert string to PlantCondition
  PlantCondition _stringToCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'healthy':
        return PlantCondition.healthy;
      case 'mild':
        return PlantCondition.mild;
      case 'moderate':
        return PlantCondition.moderate;
      case 'severe':
        return PlantCondition.severe;
      default:
        return PlantCondition.moderate;
    }
  }

  // This would be the actual implementation using TensorFlow Lite
  Future<DiagnosisResult> _realDiagnoseLeafWithModels(File imageFile) async {
    if (kIsWeb) {
      return _getMockDiagnosis();
    }

    try {
      // Mobile-only code, not executed on web
      // 1. Load and initialize models
      final resnetInterpreter = await tfl.Interpreter.fromAsset(_resnetModel);
      final efficientNetInterpreter =
          await tfl.Interpreter.fromAsset(_efficientNetModel);

      // 2. Process the image (resize, normalize, etc.)
      // This is a simplified example - actual implementation would vary
      // based on model requirements
      final imageBytes = await _processImage(imageFile);

      // 3. Run inference with ResNet model
      final resnetResults = List<List<double>>.filled(
          1, List<double>.filled(_diseaseLabels.length, 0));
      resnetInterpreter.run(imageBytes, resnetResults);

      // 4. Run inference with EfficientNet model
      final efficientNetResults = List<List<double>>.filled(
          1, List<double>.filled(_diseaseLabels.length, 0));
      efficientNetInterpreter.run(imageBytes, efficientNetResults);

      // 5. Combine results from both models (ensemble approach)
      final List<double> combinedPredictions =
          List.filled(_diseaseLabels.length, 0);
      for (int i = 0; i < _diseaseLabels.length; i++) {
        // Average the predictions (could use weighted average for better results)
        combinedPredictions[i] =
            (resnetResults[0][i] + efficientNetResults[0][i]) / 2;
      }

      // 6. Get the top prediction
      int topIndex = 0;
      double topConfidence = combinedPredictions[0];
      for (int i = 1; i < combinedPredictions.length; i++) {
        if (combinedPredictions[i] > topConfidence) {
          topConfidence = combinedPredictions[i];
          topIndex = i;
        }
      }

      // 7. Get the disease name and information
      final diseaseName = _diseaseLabels[topIndex];
      final diseaseData = await _fetchDiseaseInformation(diseaseName);

      // 8. Create and return the diagnosis result
      final condition = _stringToCondition(diseaseData['condition']);

      return DiagnosisResult(
        diseaseName: diseaseName,
        description: diseaseData['description'],
        remedies: List<String>.from(diseaseData['remedies']),
        preventionTips: List<String>.from(diseaseData['prevention_tips']),
        confidence: topConfidence,
        condition: condition,
      );
    } catch (e) {
      throw Exception('Failed to diagnose leaf image with models: $e');
    }
  }

  // Example image processing function - actual implementation would depend on model requirements
  Future<List<List<List<double>>>> _processImage(File imageFile) async {
    // This is a simplified placeholder - actual implementation would:
    // 1. Decode image
    // 2. Resize to model input dimensions
    // 3. Normalize pixel values
    // 4. Convert to appropriate tensor format
    return List.generate(
      224, // Height
      (y) => List.generate(
        224, // Width
        (x) => List.generate(3, (c) => 0.0), // RGB channels
      ),
    );
  }

  // Example function to fetch disease information from a database or API
  Future<Map<String, dynamic>> _fetchDiseaseInformation(
      String diseaseName) async {
    // In a real app, this would make an API call or query a database
    // For this example, we're using our local dataset
    return _diseaseInfo[diseaseName] ??
        {
          'description': 'Information not available for this plant disease.',
          'remedies': [
            'Consult a plant pathologist or agricultural extension service.'
          ],
          'prevention_tips': [
            'Maintain good garden hygiene.',
            'Regularly monitor plants for signs of disease.'
          ],
          'condition': 'moderate',
        };
  }

  // Additional method for web platforms
  Future<DiagnosisResult> diagnoseLeafWeb(Uint8List imageBytes) async {
    // This method is specifically for web platforms
    return _getMockDiagnosis();
  }
}
