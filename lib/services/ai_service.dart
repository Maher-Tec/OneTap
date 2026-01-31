import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:onetap/core/constants/mood_level.dart';

/// AI Service with multi-provider fallback for generating mood-aware quotes
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Cache to avoid excessive API calls
  String? _cachedQuote;
  DateTime? _cacheDate;
  MoodLevel? _cachedMood;

  /// Generate a mood-aware quote with fallback chain
  Future<String> generateMoodQuote(MoodLevel mood) async {
    // Check cache first (same day, same mood)
    final today = DateTime.now();
    if (_cachedQuote != null &&
        _cachedMood == mood &&
        _cacheDate?.day == today.day &&
        _cacheDate?.month == today.month &&
        _cacheDate?.year == today.year) {
      return _cachedQuote!;
    }

    final prompt = _buildPrompt(mood);

    // Try providers in order
    String? quote;

    // 1. OpenAI (Primary)
    quote = await _tryOpenAI(prompt);
    if (quote != null) {
      _cacheQuote(quote, mood);
      return quote;
    }

    // 2. OpenRouter (Backup #1)
    quote = await _tryOpenRouter(prompt);
    if (quote != null) {
      _cacheQuote(quote, mood);
      return quote;
    }

    // 3. Gemini (Backup #2)
    quote = await _tryGemini(prompt);
    if (quote != null) {
      _cacheQuote(quote, mood);
      return quote;
    }

    // 4. Groq (Backup #3)
    quote = await _tryGroq(prompt);
    if (quote != null) {
      _cacheQuote(quote, mood);
      return quote;
    }

    // Fallback to static quote
    return _getStaticQuote(mood);
  }

  /// Generate a short insight about the user's best day
  Future<String> generateDayInsight(String dayName, double averageMood) async {
    // Round mood to 1 decimal for cache key
    final moodKey = averageMood.toStringAsFixed(1);
    final cacheKey = '${dayName}_$moodKey';
    
    // Simple memory cache for session
    if (_insightCache.containsKey(cacheKey)) {
      return _insightCache[cacheKey]!;
    }

    final moodDesc = _getMoodDescription(averageMood);
    final prompt = 'Start with "$dayName". Write a short 1-sentence insight (max 10 words) about why $dayName is their best day. Their average mood on this day is "$moodDesc". be positive but realistic.';

    String? insight;
    
    // Try primary provider
    insight = await _tryOpenAI(prompt);
    if (insight == null) insight = await _tryOpenRouter(prompt);
    if (insight == null) insight = await _tryGemini(prompt);
    if (insight == null) insight = await _tryGroq(prompt);

    if (insight != null) {
      _insightCache[cacheKey] = insight;
      return insight;
    }

    return '$dayName seems to be your best day.';
  }

  final Map<String, String> _insightCache = {};

  String _getMoodDescription(double moodValue) {
    if (moodValue >= 4.5) return 'amazing, perfect';
    if (moodValue >= 3.5) return 'really good, happy';
    if (moodValue >= 2.5) return 'good, content';
    if (moodValue >= 1.5) return 'okay, neutral';
    return 'challenging, tough';
  }
  String _buildPrompt(MoodLevel mood) {
    final moodDescriptions = {
      MoodLevel.great: 'amazing, excited, on top of the world',
      MoodLevel.good: 'happy, content, at peace',
      MoodLevel.okay: 'neutral, just okay, neither good nor bad',
      MoodLevel.meh: 'a bit down, sad, melancholic',
      MoodLevel.bad: 'stressed, rough, having a hard time',
      MoodLevel.inLove: 'in love, heart full, romantic',
    };

    return '''Generate a short, meaningful quote (max 20 words) for someone feeling ${moodDescriptions[mood]}.
The quote should be:
- Empathetic and validating
- Not preachy or dismissive
- Warm and supportive
- Can be original or from a known author

Return ONLY the quote with author attribution (or "— Unknown" if original). No extra text.''';
  }

  void _cacheQuote(String quote, MoodLevel mood) {
    _cachedQuote = quote;
    _cachedMood = mood;
    _cacheDate = DateTime.now();
  }

  // ============ Provider Implementations ============

  Future<String?> _tryOpenAI(String prompt) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 60,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.toString().trim();
      }
    } catch (e) {
      // Silent fail, try next provider
    }
    return null;
  }

  Future<String?> _tryOpenRouter(String prompt) async {
    try {
      final apiKey = dotenv.env['OPENROUTER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://onetap.app',
        },
        body: jsonEncode({
          'model': 'openai/gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 60,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.toString().trim();
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  Future<String?> _tryGemini(String prompt) async {
    try {
      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 60,
            'temperature': 0.8,
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text']
            ?.toString()
            .trim();
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  Future<String?> _tryGroq(String prompt) async {
    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 60,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.toString().trim();
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  // ============ Static Fallback ============

  String _getStaticQuote(MoodLevel mood) {
    final quotes = {
      MoodLevel.great: '"Enjoy this moment. You earned it." — Unknown',
      MoodLevel.good: '"Today is a good day to have a good day." — Unknown',
      MoodLevel.okay: '"It\'s okay to just be okay." — Unknown',
      MoodLevel.meh: '"Even the darkest night will end." — Victor Hugo',
      MoodLevel.bad: '"You\'re doing better than you think." — Unknown',
      MoodLevel.inLove: '"Love is the answer." — John Lennon',
    };
    return quotes[mood] ?? '"Be where you are." — Unknown';
  }
}
