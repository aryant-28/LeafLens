import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  // In a real implementation, you would connect to an actual AI service API
  // For now, we'll simulate responses for demonstration purposes
  
  final List<String> _plantCareResponses = [
    'To keep your plants healthy, ensure they get adequate sunlight, water, and nutrients. Different plants have different requirements, so it\'s important to research specific needs for each species.',
    'Overwatering is a common mistake in plant care. Make sure your pots have drainage holes and wait until the top inch of soil is dry before watering again.',
    'Regular pruning helps promote plant growth and removes diseased or damaged parts. Always use clean, sharp tools when pruning to prevent spreading infections.',
    'Fertilize your plants during the growing season (spring and summer) but reduce or stop fertilizing during dormant periods (fall and winter) to avoid nutrient burn.',
    'Proper soil is essential for plant health. Most houseplants prefer well-draining potting mix, while outdoor plants may require soil amendments based on your local conditions.',
  ];
  
  final List<String> _diseaseResponses = [
    'Common plant diseases include powdery mildew, leaf spot, root rot, and various blights. Early detection is key to preventing their spread.',
    'Yellow leaves can indicate several issues: overwatering, underwatering, nutrient deficiencies, or pest problems. Check the soil moisture and look for signs of pests to narrow down the cause.',
    'Fungal diseases often thrive in humid conditions. Improve air circulation around your plants and avoid wetting the foliage when watering to prevent fungal problems.',
    'For organic disease control, neem oil, horticultural soap, and copper-based fungicides can be effective against many common plant pathogens.',
    'If your plant shows signs of viral infection (mosaic patterns, stunted growth), it\'s often best to remove the plant to prevent spread, as most plant viruses don\'t have cures.',
  ];
  
  final List<String> _fertilizerResponses = [
    'Plants need three main nutrients: nitrogen (N) for leaf growth, phosphorus (P) for roots and flowers, and potassium (K) for overall health. Most commercial fertilizers list these as "N-P-K" ratios on the packaging.',
    'Organic fertilizers like compost, manure, and bone meal release nutrients slowly and improve soil structure, while synthetic fertilizers provide immediate nutrients but don\'t improve soil health long-term.',
    'For flowering plants, choose fertilizers with higher phosphorus content (the middle number in the N-P-K ratio). For leafy plants, nitrogen-rich fertilizers work best.',
    'Slow-release fertilizers are convenient as they provide nutrients gradually over time, reducing the risk of fertilizer burn and requiring less frequent application.',
    'Always follow package instructions for fertilizer application rates. Over-fertilizing can damage plants by causing nutrient burn to the roots and foliage.',
  ];

  Future<String> sendMessage(String message) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For demonstration purposes, we're generating responses based on keywords
    // In a real implementation, you would send the message to an AI service
    final lowerMessage = message.toLowerCase();
    
    if (_containsKeywords(lowerMessage, ['fertilizer', 'nutrient', 'feed', 'feeding'])) {
      return _getRandomResponse(_fertilizerResponses);
    } else if (_containsKeywords(lowerMessage, ['disease', 'rot', 'spots', 'mildew', 'yellow', 'brown', 'wilting', 'infected'])) {
      return _getRandomResponse(_diseaseResponses);
    } else {
      return _getRandomResponse(_plantCareResponses);
    }
    
    // In a real implementation, you would have:
    // try {
    //   final response = await http.post(
    //     Uri.parse('https://your-ai-service-api.com/chat'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'message': message,
    //       'context': 'plant_care',
    //     }),
    //   );
    //   
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //     return data['response'];
    //   } else {
    //     throw Exception('Failed to get response from AI service');
    //   }
    // } catch (e) {
    //   throw Exception('Error connecting to AI service: $e');
    // }
  }
  
  bool _containsKeywords(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
  
  String _getRandomResponse(List<String> responses) {
    final random = math.Random();
    return responses[random.nextInt(responses.length)];
  }
} 