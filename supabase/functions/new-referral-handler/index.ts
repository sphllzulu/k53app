// Supabase Edge Function for handling new referral signups
// Uses Deno runtime with JSR specifier for Supabase client

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ReferralRequest {
  referral_code: string;
  referred_email: string;
  referrer_name?: string;
}

interface ReferralResponse {
  success: boolean;
  message: string;
  referral_id?: string;
  error?: string;
}

console.info('New referral handler function started');

// Use Deno.serve as per Supabase Edge Function guidelines
Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { referral_code, referred_email, referrer_name }: ReferralRequest = await req.json();

    if (!referral_code || !referred_email) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Missing required fields: referral_code and referred_email' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(referred_email)) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Invalid email format' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      );
    }

    // Create Supabase client with service role key (environment variables are pre-populated)
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Server configuration error' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500 
        }
      );
    }

    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    // Verify the referral code is a valid user ID
    const { data: referrer, error: referrerError } = await supabaseClient
      .from('profiles')
      .select('id, email, full_name')
      .eq('id', referral_code)
      .single();

    if (referrerError || !referrer) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Invalid referral code' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      );
    }

    // Check if this email has already been referred
    const { data: existingReferral, error: checkError } = await supabaseClient
      .from('referrals')
      .select('id')
      .eq('referred_email', referred_email)
      .single();

    if (!checkError && existingReferral) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'This email has already been referred' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      );
    }

    // Create referral record
    const { data: referral, error: referralError } = await supabaseClient
      .from('referrals')
      .insert({
        referrer_id: referral_code,
        referred_email: referred_email,
        referrer_name: referrer_name || referrer.full_name || referrer.email,
        status: 'pending',
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (referralError) {
      console.error('Error creating referral:', referralError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Failed to create referral record' 
        } as ReferralResponse),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500 
        }
      );
    }

    // Background task: Award points to referrer (non-blocking)
    const awardPoints = async () => {
      try {
        console.log(`Awarding points for referral: ${referral.id}`);
        
        // Update referrer's points in the database
        const { error: updateError } = await supabaseClient
          .from('profiles')
          .update({ 
            referral_points: (referrer.referral_points || 0) + 10,
            updated_at: new Date().toISOString()
          })
          .eq('id', referral_code);

        if (updateError) {
          console.error('Error awarding points:', updateError);
        } else {
          console.log(`Successfully awarded points to referrer: ${referral_code}`);
        }
      } catch (error) {
        console.error('Error in background points awarding:', error);
      }
    };

    // Run background task without blocking response
    awardPoints();

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Referral recorded successfully',
        referral_id: referral.id,
        referrer_name: referrer.full_name || referrer.email
      } as ReferralResponse),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('Error in new-referral-handler function:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: 'Internal server error' 
      } as ReferralResponse),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/new-referral-handler' \
    --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
    --header 'Content-Type: application/json' \
    --data '{
      "referral_code": "user-uuid-here",
      "referred_email": "newuser@example.com",
      "referrer_name": "John Doe"
    }'

*/
