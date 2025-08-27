// Dart Supabase Edge Function for referral signups using deno_postgres_interop
// This will be compiled to JavaScript for Deno Deploy

import 'package:deno_postgres_interop/deno_postgres_interop.dart';

// Main entry point for the edge function
void main() {
  // In Deno Deploy, this main function will be called when the worker starts
  // The actual HTTP server setup is handled by the Deno runtime
  print('Dart PostgreSQL Referral Function initialized');
}

// HTTP handler for referral signups
Future<Map<String, dynamic>> handleReferralRequest(Map<String, dynamic> request) async {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  // Handle CORS preflight requests
  if (request['method'] == 'OPTIONS') {
    return {
      'status': 200,
      'headers': corsHeaders,
      'body': 'ok'
    };
  }

  try {
    // Parse request body
    final body = request['body'];
    final referralCode = body['referral_code'] as String?;
    final referredEmail = body['referred_email'] as String?;

    // Validate required fields
    if (referralCode == null || referredEmail == null) {
      return {
        'status': 400,
        'headers': {...corsHeaders, 'Content-Type': 'application/json'},
        'body': {'error': 'Missing required fields: referral_code and referred_email'}
      };
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(referredEmail)) {
      return {
        'status': 400,
        'headers': {...corsHeaders, 'Content-Type': 'application/json'},
        'body': {'error': 'Invalid email format'}
      };
    }

    // Get database connection from environment
    // In Deno Deploy, this would be: Deno.env.get('DATABASE_URL')
    final databaseUrl = 'postgresql://user:password@host:port/database';

    // Create PostgreSQL client
    final client = Client(databaseUrl);
    await client.connect();

    try {
      // Verify the referral code is a valid user ID
      final referrerResult = await client.queryObject(
        "SELECT id, email FROM profiles WHERE id = @referralCode",
        {'referralCode': referralCode}
      );

      if (referrerResult.rows.isEmpty) {
        return {
          'status': 400,
          'headers': {...corsHeaders, 'Content-Type': 'application/json'},
          'body': {'error': 'Invalid referral code'}
        };
      }

      // Check if this email has already been referred
      final existingReferralResult = await client.queryObject(
        "SELECT id FROM referrals WHERE referred_email = @referredEmail",
        {'referredEmail': referredEmail}
      );

      if (existingReferralResult.rows.isNotEmpty) {
        return {
          'status': 400,
          'headers': {...corsHeaders, 'Content-Type': 'application/json'},
          'body': {'error': 'This email has already been referred'}
        };
      }

      // Create referral record
      final now = DateTime.now().toIso8601String();
      final referralResult = await client.queryObject(
        """
        INSERT INTO referrals (referrer_id, referred_email, status, created_at)
        VALUES (@referrerId, @referredEmail, 'pending', @createdAt)
        RETURNING id
        """,
        {
          'referrerId': referralCode,
          'referredEmail': referredEmail,
          'createdAt': now
        }
      );

      if (referralResult.rows.isEmpty) {
        return {
          'status': 500,
          'headers': {...corsHeaders, 'Content-Type': 'application/json'},
          'body': {'error': 'Failed to create referral record'}
        };
      }

      final referralId = referralResult.rows[0]['id'];

      // Background task: Award points to referrer (non-blocking simulation)
      // In a real scenario, this would be handled asynchronously
      Future.microtask(() async {
        try {
          print('Awarding points for referral: $referralId');
          // Implement point awarding logic here using additional SQL queries
        } catch (error) {
          print('Error awarding points: $error');
        }
      });

      return {
        'status': 200,
        'headers': {...corsHeaders, 'Content-Type': 'application/json'},
        'body': {
          'success': true,
          'message': 'Referral recorded successfully',
          'referral_id': referralId
        }
      };

    } finally {
      // Ensure connection is closed
      await client.end();
    }

  } catch (error) {
    print('Error in referral function: $error');
    return {
      'status': 500,
      'headers': {...corsHeaders, 'Content-Type': 'application/json'},
      'body': {'error': 'Internal server error', 'details': error.toString()}
    };
  }
}

// Main request handler that would be called by Deno.serve equivalent
Future<Map<String, dynamic>> handleHttpRequest(Map<String, dynamic> request) async {
  // This simulates the Deno.serve request handling
  // In the compiled JavaScript, this would receive actual Request objects
  
  try {
    // For demonstration, we'll simulate a request
    // In real usage, this would parse the actual HTTP request
    final simulatedRequest = {
      'method': 'POST',
      'body': {
        'referral_code': 'test123',
        'referred_email': 'test@example.com'
      }
    };
    
    return await handleReferralRequest(simulatedRequest);
  } catch (e) {
    return {
      'status': 500,
      'headers': {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      'body': {'error': 'Internal server error', 'details': e.toString()}
    };
  }
}