import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/referral.dart';
import './database_service.dart';
import './supabase_service.dart';
import './gamification_service.dart';
import '../models/achievement.dart';
import '../config/environment_config.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // Share content via WhatsApp or other platforms
  Future<void> shareContent(ShareContent content) async {
    try {
      final text = '${content.title}\n\n${content.message}${content.deepLink != null ? '\n\n${content.deepLink}' : ''}';
      
      await Share.share(
        text,
        subject: content.title,
      );

      // Track share event
      await _trackShareEvent(content);
    } catch (e) {
      print('Error sharing content: $e');
    }
  }

  // Share content specifically via WhatsApp with deep linking
  Future<void> shareViaWhatsApp(ShareContent content) async {
    try {
      final text = '${content.title}\n\n${content.message}${content.deepLink != null ? '\n\n${content.deepLink}' : ''}';
      
      // Encode the text for URL
      final encodedText = Uri.encodeComponent(text);
      final whatsappUrl = 'whatsapp://send?text=$encodedText';
      
      // Try to launch WhatsApp
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
        
        // Track share event
        await _trackShareEvent(content, platform: 'whatsapp');
      } else {
        // Fallback to generic share if WhatsApp is not installed
        await shareContent(content);
      }
    } catch (e) {
      print('Error sharing via WhatsApp: $e');
      // Fallback to generic share
      await shareContent(content);
    }
  }

  // Share referral link via WhatsApp
  Future<void> shareReferralLink() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Generate referral link with UTM parameters
      final referralLink = _generateReferralLink(userId);
      
      final content = ShareContent(
        title: 'Join me on K53 Learner\'s License App!',
        message: 'I\'m using this amazing app to study for my K53 learner\'s license. '
                 'It has practice questions, mock exams, and great explanations. '
                 'Join me and let\'s study together!',
        deepLink: referralLink,
      );

      await shareViaWhatsApp(content);

      // Track referral share with edge function
      await _trackWhatsAppReferralShare(userId);
    } catch (e) {
      print('Error sharing referral link: $e');
    }
  }

  // Generate referral link with UTM tracking
  String _generateReferralLink(String userId) {
    final baseUrl = 'https://k53app.com/download'; // Replace with actual app store link
    return '$baseUrl?ref=$userId&utm_source=whatsapp&utm_medium=referral&utm_campaign=user_$userId';
  }

  // Track share event for analytics
  Future<void> _trackShareEvent(ShareContent content, {String platform = 'whatsapp'}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      await DatabaseService.trackShareEvent(
        userId: userId,
        platform: platform,
        contentType: content.title,
        success: true,
      );
    } catch (e) {
      print('Error tracking share event: $e');
    }
  }

  // Track WhatsApp referral share using edge function
  Future<void> _trackWhatsAppReferralShare(String userId) async {
    try {
      final supabaseUrl = EnvironmentConfig.supabaseUrl;
      final functionUrl = '$supabaseUrl/functions/v1/whatsapp-referral-tracker';
      
      final referralCode = _generateReferralCode(userId);
      
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_type': 'share',
          'referrer_id': userId,
          'referral_code': referralCode,
          'campaign_source': 'whatsapp',
          'campaign_medium': 'social',
          'campaign_name': 'k53-referral',
          'deep_link': _generateReferralLink(userId),
          'platform': 'whatsapp',
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to track WhatsApp referral: ${response.body}');
        // Fallback to local tracking
        await DatabaseService.trackReferralShare(userId);
      }
    } catch (e) {
      print('Error tracking WhatsApp referral: $e');
      // Fallback to local tracking
      await DatabaseService.trackReferralShare(userId);
    }
  }

  // Generate a referral code from user ID
  String _generateReferralCode(String userId) {
    // Use first 8 characters of user ID as referral code
    return userId.substring(0, 8).toUpperCase();
  }

  // Handle referral signup (when someone signs up using referral link)
  Future<void> handleReferralSignup(String referrerId, String referredEmail) async {
    try {
      // Create referral record using direct database operations
      final referral = await DatabaseService.createReferral(
        referrerId: referrerId,
        referredEmail: referredEmail,
      );

      if (referral != null) {
        // Award points to referrer
        await GamificationService().trackProgress(
          type: AchievementType.social,
          value: 1,
          userId: referrerId,
        );

        // Track referral completion
        await DatabaseService.trackReferralCompletion(referral.id);
      }
    } catch (e) {
      print('Error handling referral signup: $e');
    }
  }

  // Get user's referral stats
  Future<Map<String, dynamic>> getReferralStats() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {};

    try {
      return await DatabaseService.getReferralStats(userId);
    } catch (e) {
      print('Error getting referral stats: $e');
      return {};
    }
  }

  // Get user's referral history
  Future<List<Referral>> getReferralHistory() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    try {
      return await DatabaseService.getUserReferrals(userId);
    } catch (e) {
      print('Error getting referral history: $e');
      return [];
    }
  }
}