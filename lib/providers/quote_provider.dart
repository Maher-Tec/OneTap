import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/services/ai_service.dart';

/// Provider for AI-generated mood quotes
/// Uses FutureProvider.family to cache quotes per mood
final aiQuoteProvider = FutureProvider.family<String, MoodLevel>((ref, mood) async {
  final aiService = AiService();
  return aiService.generateMoodQuote(mood);
});
